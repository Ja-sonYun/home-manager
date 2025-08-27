local M = {}

--- Configuration
M.config = {
	keymap = "ql",
	timeout = 10000, -- 10 seconds
	save_before_format = true,
}

vim.keymap.set("n", M.config.keymap, function()
	if not M.format_current() then
		vim.notify("No formatter available for current filetype", vim.log.levels.WARN)
	end
end, {
	buffer = true,
	desc = "Format current buffer",
	nowait = true,
})

--- Registered formatters by filetype or directory
M._formatters = {}

--- Compare two line arrays
--- @param lines1 table First array of lines
--- @param lines2 table Second array of lines
--- @return boolean true if arrays are identical
local function lines_equal(lines1, lines2)
	if #lines1 ~= #lines2 then
		return false
	end
	for i = 1, #lines1 do
		if lines1[i] ~= lines2[i] then
			return false
		end
	end
	return true
end

--- Simple format function - the main entry point
--- @param cmd string|table Command(s) to run on the file
--- @param opts table|nil Options
--- @return boolean success
M.format = function(cmd, opts)
	opts = opts or {}

	-- Validate command
	if not cmd then
		vim.notify("No formatter command provided", vim.log.levels.ERROR)
		return false
	end

	-- Convert single command to table
	if type(cmd) == "string" then
		cmd = { cmd }
	end

	if type(cmd) ~= "table" or #cmd == 0 then
		vim.notify("Invalid formatter command", vim.log.levels.ERROR)
		return false
	end

	-- Save buffer if needed
	if M.config.save_before_format and vim.bo.modified then
		vim.cmd("write")
	end

	-- Get current buffer content
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local content = table.concat(lines, "\n")

	-- Create temporary file
	local tmpfile = vim.fn.tempname()
	local tmpdir = vim.fn.fnamemodify(tmpfile, ":h")
	local filename = vim.fn.expand("%:t")
	local ext = vim.fn.expand("%:e")

	-- Use original filename with extension for better formatter recognition
	if filename ~= "" then
		tmpfile = tmpdir .. "/" .. filename
	elseif ext ~= "" then
		tmpfile = tmpfile .. "." .. ext
	end

	-- Write content to temp file
	local ok = pcall(vim.fn.writefile, lines, tmpfile)
	if not ok then
		vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
		return false
	end

	-- Run formatter commands
	local success = true
	local cwd = opts.cwd or vim.fn.expand("%:p:h")

	for i, command in ipairs(cmd) do
		-- Replace % with temp file path
		local formatted_cmd = command:gsub("%%", vim.fn.shellescape(tmpfile))

		local result
		if vim.system then
			-- Modern Neovim
			result = vim.system({ "sh", "-c", formatted_cmd }, {
				cwd = cwd,
				timeout = M.config.timeout,
				text = true,
			}):wait()
		else
			-- Fallback for older versions
			local prev_cwd = vim.fn.getcwd()
			vim.cmd("cd " .. vim.fn.fnameescape(cwd))
			vim.fn.system(formatted_cmd)
			result = { code = vim.v.shell_error }
			vim.cmd("cd " .. vim.fn.fnameescape(prev_cwd))
		end

		if result.code ~= 0 then
			local error_msg = string.format("Formatter command %d failed: %s", i, formatted_cmd)
			if result.stderr and result.stderr ~= "" then
				error_msg = error_msg .. "\n" .. result.stderr
			end
			vim.notify(error_msg, vim.log.levels.ERROR)
			success = false
			break
		end
	end

	-- Read formatted content and update buffer
	if success then
		local formatted_lines = vim.fn.readfile(tmpfile)
		if formatted_lines then
			-- Check if content has changed
			if not lines_equal(lines, formatted_lines) then
				-- Preserve cursor position
				local cursor = vim.api.nvim_win_get_cursor(0)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
				-- Restore cursor position (with bounds checking)
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				cursor[1] = math.min(cursor[1], line_count)
				vim.api.nvim_win_set_cursor(0, cursor)
				if not opts.silent then
					vim.notify("Formatted successfully")
				end
			else
				if not opts.silent then
					vim.notify("No formatting changes")
				end
			end
		else
			vim.notify("Failed to read formatted content", vim.log.levels.ERROR)
			success = false
		end
	end

	-- Cleanup
	pcall(vim.fn.delete, tmpfile)

	return success
end

--- Register a formatter for a filetype
--- @param filetype string Filetype to register for
--- @param cmd string|table|function Command(s) or function that returns commands
--- @param opts table|nil Options
M.register = function(filetype, cmd, opts)
	if type(filetype) ~= "string" or filetype == "" then
		vim.notify("Invalid filetype for formatter registration", vim.log.levels.ERROR)
		return
	end

	M._formatters[filetype] = {
		cmd = cmd,
		opts = opts or {},
	}

	-- Set up buffer-local keymap immediately if we're in the right filetype
	if vim.bo.filetype == filetype then
		vim.keymap.set("n", M.config.keymap, function()
			M.format_current()
		end, {
			buffer = true,
			desc = "Format current buffer",
			nowait = true,
		})
	end
end

--- Format current buffer using registered formatter
--- @return boolean success
M.format_current = function()
	local filetype = vim.bo.filetype

	if not filetype or filetype == "" then
		vim.notify("No filetype detected", vim.log.levels.WARN)
		return false
	end

	local formatter = M._formatters[filetype]
	if not formatter then
		vim.notify("No formatter registered for filetype: " .. filetype, vim.log.levels.WARN)
		return false
	end

	local cmd = formatter.cmd

	-- If cmd is a function, call it
	if type(cmd) == "function" then
		cmd = cmd()
	end

	return M.format(cmd, formatter.opts)
end

--- List registered formatters
--- @param filetype string|nil Optional filetype filter
--- @return table
M.list_formatters = function(filetype)
	if filetype then
		local formatter = M._formatters[filetype]
		if formatter then
			return {
				filetype = filetype,
				cmd = formatter.cmd,
				opts = formatter.opts,
			}
		else
			return nil
		end
	end

	local result = {}
	for ft, formatter in pairs(M._formatters) do
		table.insert(result, {
			filetype = ft,
			cmd = formatter.cmd,
			opts = formatter.opts,
		})
	end

	-- Sort by filetype for consistent output
	table.sort(result, function(a, b)
		return a.filetype < b.filetype
	end)
	return result
end

--- Remove formatter registration
--- @param filetype string Filetype to unregister
M.unregister = function(filetype)
	if type(filetype) ~= "string" or filetype == "" then
		vim.notify("Invalid filetype for unregistration", vim.log.levels.ERROR)
		return false
	end

	local existed = M._formatters[filetype] ~= nil
	M._formatters[filetype] = nil
	return existed
end

--- Check if formatter is available
--- @param filetype string Filetype to check
--- @return boolean
M.has_formatter = function(filetype)
	return M._formatters[filetype] ~= nil
end

--- Get formatter for current buffer or specified filetype
--- @param filetype string|nil Filetype to check (defaults to current buffer)
--- @return table|nil Formatter configuration
M.get_formatter = function(filetype)
	filetype = filetype or vim.bo.filetype
	if not filetype or filetype == "" then
		return nil
	end
	return M._formatters[filetype]
end

--- Set up user commands for formatter management
M.setup_commands = function()
	vim.keymap.set("n", M.config.keymap, function()
		vim.notify("No formatter registered for current filetype", vim.log.levels.WARN)
	end, {
		buffer = true,
		desc = "Format current buffer",
		nowait = true,
	})

	-- List all registered formatters or specific filetype
	vim.api.nvim_create_user_command("FormatList", function(opts)
		local filetype = opts.args ~= "" and opts.args or nil
		local formatters = M.list_formatters(filetype)

		if not formatters then
			vim.print("No formatter registered for: " .. (filetype or "unknown"), vim.log.levels.WARN)
			return
		end

		if filetype then
			-- Single formatter
			local cmd_str = type(formatters.cmd) == "function" and "function()"
				or type(formatters.cmd) == "table" and table.concat(formatters.cmd, ", ")
				or tostring(formatters.cmd)
			vim.print(string.format("Formatter for %s: %s", formatters.filetype, cmd_str))
		else
			-- All formatters
			if #formatters == 0 then
				vim.print("No formatters registered", vim.log.levels.WARN)
				return
			end

			local lines = { "Registered formatters:" }
			for _, f in ipairs(formatters) do
				local cmd_str = type(f.cmd) == "function" and "function()"
					or type(f.cmd) == "table" and table.concat(f.cmd, ", ")
					or tostring(f.cmd)
				table.insert(lines, string.format("  %s: %s", f.filetype, cmd_str))
			end
			vim.print(table.concat(lines, "\n"))
		end
	end, {
		nargs = "?",
		desc = "List registered formatters",
		complete = function()
			local filetypes = {}
			for ft, _ in pairs(M._formatters) do
				table.insert(filetypes, ft)
			end
			return filetypes
		end,
	})

	-- Remove formatter registration
	vim.api.nvim_create_user_command("FormatUnregister", function(opts)
		if opts.args == "" then
			vim.print("Please specify a filetype to unregister", vim.log.levels.ERROR)
			return
		end

		local existed = M.unregister(opts.args)
		if existed then
			vim.print("Unregistered formatter for: " .. opts.args)
		else
			vim.print("No formatter was registered for: " .. opts.args, vim.log.levels.WARN)
		end
	end, {
		nargs = 1,
		desc = "Unregister formatter for filetype",
		complete = function()
			local filetypes = {}
			for ft, _ in pairs(M._formatters) do
				table.insert(filetypes, ft)
			end
			return filetypes
		end,
	})

	-- Check if formatter exists
	vim.api.nvim_create_user_command("FormatCheck", function(opts)
		local filetype = opts.args ~= "" and opts.args or vim.bo.filetype
		if not filetype or filetype == "" then
			vim.print("No filetype specified or detected", vim.log.levels.ERROR)
			return
		end

		local has_fmt = M.has_formatter(filetype)
		local status = has_fmt and "Available" or "Not available"
		vim.print(string.format("Formatter for %s: %s", filetype, status))
	end, {
		nargs = "?",
		desc = "Check if formatter is available for filetype",
		complete = function()
			-- Return common filetypes
			return { "lua", "python", "javascript", "typescript", "rust", "go", "c", "cpp" }
		end,
	})
end

-- Auto-setup commands when module is loaded
M.setup_commands()

return M
