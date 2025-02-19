local M = {}

M.print = function(any)
	if type(any) == "table" then
		print(vim.inspect(any))
	else
		print(any)
	end
end

M.mark_as_loaded = function(name)
	local plugin_key = "did_load_" .. name .. "_plugin"
	if vim.g[plugin_key] then
		return true
	end
	vim.g[plugin_key] = true
end

return M
