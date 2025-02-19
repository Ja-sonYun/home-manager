local M = {}

M.key = "ql"
M.tempdir = ".tmp"

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
	local uuid = require("modules.util").uuid()
	local tmpfile = nil
	if opts.run_in_cwd then
		local tempdir = opts.dir .. "/" .. M.tempdir
		if vim.fn.isdirectory(tempdir) == 0 then
			vim.fn.mkdir(tempdir)
		end
		tmpfile = tempdir .. "/" .. uuid
	else
		tmpfile = vim.fn.tempname()
	end

	local current_file_suffix = vim.fn.expand("%:t"):match(".+%.(.+)")
	if opts.suffix then
		tmpfile = tmpfile .. opts.suffix
	else
		tmpfile = tmpfile .. "." .. current_file_suffix
	end

	vim.cmd("write! " .. tmpfile)

	for _, cmd in ipairs(cmd_list) do
		local command = cmd:gsub("%%", tmpfile)
		command = "cd " .. opts.dir .. " && " .. command
		local stdout = vim.fn.system(command)
		local exit_code = vim.v.shell_error
		if exit_code ~= 0 then
			vim.fn.delete(tmpfile)
			vim.notify("Failed to format", vim.log.levels.ERROR)
			error(stdout)
			return
		end
	end

	local new_content = vim.fn.readfile(tmpfile)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_content)
	vim.fn.delete(tmpfile)
	vim.notify("Formatted")
end

--- Register a formatter with the given command list
--- @param func function
--- @param opts? module.formatter.format_with_command
--- @return nil
M.register_formatter = function(func, opts)
	if M._registered_formatters == nil then
		M._registered_formatters = {}
	end

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
			vim.notify("Found registered formatter")
			return
		end
	end

	local cmd_list = func()
	if opts.dir then
		M._registered_formatters[opts.dir] = cmd_list
	end

	vim.notify("Registered formatter with " .. table.concat(cmd_list, " && "), "info")
	vim.keymap.set("n", M.key, function()
		M.format_with_command(cmd_list, opts)
	end, { buffer = true, nowait = true })
end

return M
