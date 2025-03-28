local M = {}

M._registered_python_paths = {}

--- Get the path to the Python executable.
--- @param workspace string|nil
--- @return string
--- @return string|nil
M.get_python_path = function(workspace)
	local Path = require("plenary.path")
	local current_folder = workspace or vim.fn.expand("%:p:h")

	local founded_keys = require("modules.table").keys(M._registered_python_paths)
	table.sort(founded_keys, function(a, b)
		return #a > #b
	end)
	for _, key in ipairs(founded_keys) do
		if current_folder:find(key, 1, true) then
			local venv_path, venv_dir = unpack(M._registered_python_paths[key])
			return venv_path, venv_dir
		end
	end

	local home = os.getenv("HOME")

	while current_folder do
		if current_folder == home then
			break
		end -- If only root remains, exit

		-- if .pyvenv.cfg exists, use it. it will include absolute path to venv
		local venv_cfg = Path:new(current_folder, ".pyvenv")
		if venv_cfg:exists() then
			local venv_path = Path:new(venv_cfg:readlines()[1]):absolute()
			M._registered_python_paths[current_folder] = { venv_path, current_folder }
			return venv_path, current_folder
		end

		-- Find and use virtualenv in workspace directory.
		-- Search for parent dir, sometimes vim-rooter use src folder
		for _, pattern in ipairs({ ".venv" }) do
			local pyvenv_flag = Path:new(current_folder, pattern, "pyvenv.cfg")
			if pyvenv_flag:exists() then
				local venv_path = Path:new(current_folder, pattern, "bin", "python3"):absolute()
				M._registered_python_paths[current_folder] = { venv_path, current_folder }
				return venv_path, current_folder
			end
		end
		-- Remove the last '/segment'
		local new = current_folder:match("(.+)/[^/]+$")
		current_folder = new
	end

	local venv_env_path = os.getenv("VIRTUAL_ENV")
	-- Use activated virtualenv.
	if venv_env_path then
		-- Join paths using Plenary's Path:new(...)
		local venv_path = Path:new(venv_env_path, "bin", "python3"):absolute()
		M._registered_python_paths[venv_env_path] = { venv_path, venv_env_path }
		return venv_path, venv_env_path
	end

	-- Fallback to system Python.
	return vim.g.python3_host_prog, nil
end

return M
