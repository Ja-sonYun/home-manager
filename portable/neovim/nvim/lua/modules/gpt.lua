local M = {}

-- OpenAI Chat Completions API client for Neovim
local uv = vim.uv or vim.loop

--- Configuration for OpenAI API
M.config = {
	model = "gpt-5",
	timeout = 30000, -- 30 seconds
	max_tokens = 4096,
	temperature = 0.7,
	retry_count = 2,
	retry_delay = 1000, -- 1 second
}

-- Active requests tracking
M._active_requests = {}

--- Validate input parameters
local function validate_params(texts, instruction, callback)
	if type(callback) ~= "function" then
		vim.notify("`callback` must be a function", vim.log.levels.ERROR)
		return false
	end

	if type(texts) ~= "string" or texts == "" then
		vim.notify("`texts` must be a non-empty string", vim.log.levels.ERROR)
		return false
	end

	if instruction and type(instruction) ~= "string" then
		vim.notify("`instruction` must be a string or nil", vim.log.levels.ERROR)
		return false
	end

	return true
end

--- Get API key from environment
local function get_api_key()
	local api_key = vim.env.OPENAI_API_KEY
	if not api_key or api_key == "" then
		vim.schedule(function()
			vim.notify("OPENAI_API_KEY environment variable is not set", vim.log.levels.ERROR)
		end)
		return nil
	end
	return api_key
end

--- Build chat messages array
local function build_messages(texts, instruction)
	local messages = { { role = "user", content = texts } }
	if instruction and instruction ~= "" then
		table.insert(messages, 1, { role = "system", content = instruction })
	end
	return messages
end

--- Build request payload
local function build_payload(messages)
	return vim.fn.json_encode({
		model = M.config.model,
		messages = messages,
		max_tokens = M.config.max_tokens,
		temperature = M.config.temperature,
		stream = false,
	})
end

--- Process API response
local function process_response(chunks, callback, on_error)
	local response_text = table.concat(chunks)
	local ok, resp = pcall(vim.fn.json_decode, response_text)

	if not ok then
		on_error("Failed to parse OpenAI response: Invalid JSON")
		return
	end

	-- Check for API errors
	if resp.error then
		on_error("OpenAI API error: " .. (resp.error.message or "Unknown error"))
		return
	end

	-- Validate response structure
	if not resp.choices or #resp.choices == 0 then
		on_error("Invalid response: No choices returned")
		return
	end

	local message = resp.choices[1].message
	if not message or not message.content then
		on_error("Invalid response: No content in message")
		return
	end

	-- Success - call callback with content
	callback(message.content)
end

--- Create a cancellable request
local function create_request(api_key, payload, callback, retry_count)
	local request = {
		handle = nil,
		stdout = nil,
		stderr = nil,
		cancelled = false,
		timer = nil,
	}

	-- Setup pipes
	request.stdout = uv.new_pipe(false)
	request.stderr = uv.new_pipe(false)
	local chunks = {}
	local stderr_chunks = {}

	-- curl arguments
	local args = {
		"-sS",
		"-f",
		"--max-time",
		tostring(math.floor(M.config.timeout / 1000)),
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
		"-d",
		payload,
		"https://api.openai.com/v1/chat/completions",
	}

	-- Error handler
	local function on_error(error_msg)
		if request.cancelled then
			return
		end

		-- Clean up
		if request.timer then
			uv.timer_stop(request.timer)
			uv.close(request.timer)
		end

		-- Retry logic
		if retry_count > 0 then
			vim.schedule(function()
				vim.notify("Retrying OpenAI request... (" .. retry_count .. " attempts left)", vim.log.levels.WARN)
			end)

			-- Retry after delay
			vim.defer_fn(function()
				if not request.cancelled then
					create_request(api_key, payload, callback, retry_count - 1)
				end
			end, M.config.retry_delay)
		else
			vim.schedule(function()
				vim.notify(error_msg, vim.log.levels.ERROR)
			end)
		end
	end

	-- Spawn curl process
	local handle, pid = uv.spawn("curl", {
		args = args,
		stdio = { nil, request.stdout, request.stderr },
	}, function(code)
		request.stdout:close()
		request.stderr:close()
		if request.handle then
			request.handle:close()
		end

		-- Remove from active requests
		for i, req in ipairs(M._active_requests) do
			if req == request then
				table.remove(M._active_requests, i)
				break
			end
		end

		if request.cancelled then
			return
		end

		vim.schedule(function()
			if code ~= 0 then
				local error_info = table.concat(stderr_chunks)
				on_error(("OpenAI request failed (exit %d): %s"):format(code, error_info))
				return
			end

			process_response(chunks, callback, on_error)
		end)
	end)

	request.handle = handle

	if not request.handle then
		on_error("Failed to spawn curl process")
		return nil
	end

	-- Read stdout
	uv.read_start(request.stdout, function(err, data)
		if err then
			on_error("Error reading stdout: " .. err)
			return
		end
		if data then
			table.insert(chunks, data)
		end
	end)

	-- Read stderr
	uv.read_start(request.stderr, function(err, data)
		if err then
			on_error("Error reading stderr: " .. err)
			return
		end
		if data then
			table.insert(stderr_chunks, data)
		end
	end)

	-- Add timeout timer
	request.timer = uv.new_timer()
	uv.timer_start(request.timer, M.config.timeout, 0, function()
		if not request.cancelled then
			request.cancelled = true
			if request.handle and not uv.is_closing(request.handle) then
				uv.process_kill(request.handle, "sigterm")
			end
			on_error("Request timed out after " .. (M.config.timeout / 1000) .. " seconds")
		end
	end)

	return request
end

--- Call OpenAI Chat Completions API
--- @param texts string The user message content
--- @param instruction string|nil Optional system instruction
--- @param callback function Callback function to handle response
--- @return table|nil Request handle that can be cancelled
M.call_api = function(texts, instruction, callback)
	-- Validate parameters
	if not validate_params(texts, instruction, callback) then
		return nil
	end

	-- Get API key
	local api_key = get_api_key()
	if not api_key then
		return nil
	end

	-- Build request
	local messages = build_messages(texts, instruction)
	local payload = build_payload(messages)

	-- Create cancellable request
	local request = create_request(api_key, payload, callback, M.config.retry_count)
	if request then
		table.insert(M._active_requests, request)
		return request
	end

	return nil
end

--- Cancel a request
--- @param request table The request handle returned by call_api
M.cancel_request = function(request)
	if not request or request.cancelled then
		return
	end

	request.cancelled = true

	-- Stop timer
	if request.timer and not uv.is_closing(request.timer) then
		uv.timer_stop(request.timer)
		uv.close(request.timer)
	end

	-- Kill process
	if request.handle and not uv.is_closing(request.handle) then
		uv.process_kill(request.handle, "sigterm")
	end
end

--- Cancel all active requests
M.cancel_all_requests = function()
	for _, request in ipairs(M._active_requests) do
		M.cancel_request(request)
	end
	M._active_requests = {}
end

--- Update configuration
--- @param opts table Configuration options
M.setup = function(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})
end

return M
