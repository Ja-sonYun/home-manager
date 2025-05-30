local M = {}

M.key = "ql"
M.tempdir = ".tmp"

M._registered_formatters = {}

--- @class module.formatter.format_with_command
--- @field dir? string
--- @field suffix? string
--- @field run_in_cwd? boolean

--- Format the current buffer with the given command
--- @param cmd_list string[]
--- @param opts module.formatter.format_with_command
--- @return nil
M.format_with_command = function(cmd_list, opts)
	if opts == nil then
		opts = {}
	end
	if opts.dir == nil then
		opts.dir = vim.fn.getcwd()
	end

	-- original filename (e.g. "main.ts")
	local original_filename = vim.fn.expand("%:t")
	local tmpfile

	if opts.run_in_cwd then
		local tempdir = opts.dir .. "/" .. M.tempdir
		if vim.fn.isdirectory(tempdir) == 0 then
			vim.fn.mkdir(tempdir, "p")
		end
		tmpfile = tempdir .. "/" .. original_filename
	else
		local tmpdir = vim.fn.tempname()
		vim.fn.mkdir(tmpdir)
		tmpfile = tmpdir .. "/" .. original_filename
	end

	vim.cmd("write! " .. tmpfile)

	local new_content = nil
	local ok, err = pcall(function()
		-- run each formatter command
		for _, cmd in ipairs(cmd_list) do
			local command = cmd:gsub("%%", tmpfile)
			command = "cd " .. opts.dir .. " && " .. command
			local ret_msg = vim.fn.system(command)
			if vim.v.shell_error ~= 0 then
				-- propagate error to outer pcall
				error(ret_msg)
			end
		end
		-- read formatted result
		new_content = vim.fn.readfile(tmpfile)
	end)
	if vim.fn.filereadable(tmpfile) == 1 then
		vim.fn.delete(tmpfile)
	end

	if not ok then
		vim.notify("Failed to format", vim.log.levels.ERROR)
		error(err) -- rethrow for caller / stack trace
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_content)
	vim.notify("Formatted")
end

--- Register a formatter with the given command list
--- @param func function
--- @param opts? module.formatter.format_with_command
--- @return nil
M.register_formatter = function(func, opts)
	if opts == nil then
		opts = {}
	end
	if opts.dir == nil then
		opts.dir = vim.fn.getcwd()
	end

	local current_folder = vim.fn.expand("%:p:h")
	local founded_keys = require("modules.table").keys(M._registered_formatters)
	table.sort(founded_keys, function(a, b)
		return #a > #b
	end)
	for _, key in ipairs(founded_keys) do
		if current_folder:find(key, 1, true) then
			vim.keymap.set("n", M.key, function()
				M.format_with_command(M._registered_formatters[key], opts)
			end, { buffer = true, nowait = true })
			return
		end
	end

	local cmd_list = func()
	if opts.dir then
		M._registered_formatters[opts.dir] = cmd_list
	end

	vim.keymap.set("n", M.key, function()
		M.format_with_command(cmd_list, opts)
	end, { buffer = true, nowait = true })
end

return M
