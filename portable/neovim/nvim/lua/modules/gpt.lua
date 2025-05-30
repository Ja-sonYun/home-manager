local M = {}

-- openai.lua
-- A tiny helper to call the OpenAI Chat Completions endpoint from Neovim.
local uv = vim.uv or vim.loop

M.call_api = function(texts, instruction, callback)
	-- Validate callback
	assert(type(callback) == "function", "`callback` must be a function")

	-- Validate API key
	local api_key = vim.env.OPENAI_API_KEY
	if not api_key or api_key == "" then
		vim.schedule(function()
			vim.notify("OPENAI_API_KEY environment variable is not set", vim.log.levels.ERROR)
		end)
		return
	end

	-- Prepare chat messages
	local messages = { { role = "user", content = texts } }
	if instruction and instruction ~= "" then
		table.insert(messages, 1, { role = "system", content = instruction })
	end

	-- JSON payload
	local payload = vim.fn.json_encode({
		model = "gpt-4.1",
		messages = messages,
		stream = false,
	})

	-- curl arguments (pass as argv → no shell-escaping headache)
	local args = {
		"-sS", -- silent, but still show HTTP errors
		"-f", -- fail if HTTP status ≥400
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
		"-d",
		payload,
		"https://api.openai.com/v1/chat/completions",
	}

	-- Pipes & handle
	local stdout, stderr = uv.new_pipe(false), uv.new_pipe(false)
	local chunks = {}
	local handle
	handle = uv.spawn("curl", { args = args, stdio = { nil, stdout, stderr } }, function(code)
		stdout:close()
		stderr:close()
		handle:close()

		if code ~= 0 then
			vim.schedule(function()
				vim.notify(("OpenAI request failed (exit %d)"):format(code), vim.log.levels.ERROR)
			end)
			return
		end

		vim.schedule(function()
			local ok, resp = pcall(vim.fn.json_decode, table.concat(chunks))
			if not ok or not (resp and resp.choices) then
				vim.notify("Failed to parse OpenAI response", vim.log.levels.ERROR)
				return
			end
			local text = resp.choices[1].message.content:gsub("<%d+>", "")
			callback(text)
		end)
	end)

	-- Read stdout
	uv.read_start(stdout, function(err, data)
		assert(not err, err)
		if data then
			table.insert(chunks, data)
		end
	end)

	-- Read stderr (show as Neovim notifications)
	uv.read_start(stderr, function(_, data)
		if data then
			vim.schedule(function()
				vim.notify("[OpenAI stderr] " .. data, vim.log.levels.WARN)
			end)
		end
	end)
end

return M
