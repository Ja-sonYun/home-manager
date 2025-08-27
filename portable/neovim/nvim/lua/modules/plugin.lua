local M = {}

--- Print any value with proper formatting
--- @param value any The value to print
--- @param prefix string|nil Optional prefix for the output
--- @return nil
M.print = function(value, prefix)
	local output
	if type(value) == "table" then
		output = vim.inspect(value, {
			indent = "  ",
			depth = 3,
		})
	elseif type(value) == "nil" then
		output = "nil"
	elseif type(value) == "boolean" then
		output = tostring(value)
	elseif type(value) == "function" then
		output = "function: " .. tostring(value)
	else
		output = tostring(value)
	end

	if prefix then
		print(prefix .. ": " .. output)
	else
		print(output)
	end
end

--- Debug print with source location
--- @param value any The value to print
--- @param msg string|nil Optional message
--- @return nil
M.debug_print = function(value, msg)
	local info = debug.getinfo(2, "Sl")
	local location = string.format("[%s:%d]", info.short_src or "unknown", info.currentline or 0)
	local prefix = msg and (location .. " " .. msg) or location
	M.print(value, prefix)
end

--- Check if a plugin is loaded and mark it as loaded
--- @param name string Plugin name
--- @return boolean true if already loaded, false if newly marked
M.mark_as_loaded = function(name)
	if type(name) ~= "string" or name == "" then
		vim.notify("Plugin name must be a non-empty string", vim.log.levels.ERROR)
		return false
	end

	local plugin_key = "did_load_" .. name:gsub("[^%w_]", "_") .. "_plugin"

	if vim.g[plugin_key] then
		return true
	end

	vim.g[plugin_key] = true
	return false
end

return M
