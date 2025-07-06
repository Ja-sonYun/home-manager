local M = {}

-- Cache for resolved paths
M._cache = {}

-- Configuration
M.config = {
	venv_patterns = { ".venv", "venv", "env", ".env" },
	python_names = { "python3", "python" },
	max_depth = 10,
	cache_timeout = 300,
}

--- Check if plenary is available
local function check_plenary()
	local ok, Path = pcall(require, "plenary.path")
	if not ok then
		vim.notify("plenary.nvim is required for Python path resolution", vim.log.levels.ERROR)
		return false, nil
	end
	return true, Path
end

--- Check if cache entry is valid
local function is_cache_valid(entry)
	return entry and (os.time() - entry.timestamp) < M.config.cache_timeout
end

--- Find Python executable in virtual environment
local function find_python_in_venv(Path, venv_dir)
	local dirs = { Path:new(venv_dir, "bin"), Path:new(venv_dir, "Scripts") }

	for _, dir in ipairs(dirs) do
		for _, name in ipairs(M.config.python_names) do
			local python = dir:joinpath(name)
			if python:exists() and python:is_file() then
				return python:absolute()
			end

			-- Windows .exe
			local exe = dir:joinpath(name .. ".exe")
			if exe:exists() and exe:is_file() then
				return exe:absolute()
			end
		end
	end
	return nil
end

--- Search for virtual environment in directory
local function search_venv_in_directory(Path, directory)
	-- Check .pyvenv file first
	local pyvenv_file = Path:new(directory, ".pyvenv")
	if pyvenv_file:exists() then
		local ok, lines = pcall(pyvenv_file.readlines, pyvenv_file)
		if ok and lines and lines[1] and lines[1] ~= "" then
			local python_path = Path:new(lines[1]):absolute()
			if Path:new(python_path):exists() then
				return python_path, directory
			end
		end
	end

	-- Search for virtual environment patterns
	for _, pattern in ipairs(M.config.venv_patterns) do
		local venv_candidate = Path:new(directory, pattern)
		local pyvenv_cfg = venv_candidate:joinpath("pyvenv.cfg")

		if pyvenv_cfg:exists() then
			local python_path = find_python_in_venv(Path, venv_candidate:absolute())
			if python_path then
				return python_path, venv_candidate:absolute()
			end
		end
	end

	return nil, nil
end

--- Get the path to the Python executable
M.get_python_path = function(workspace)
	local ok, Path = check_plenary()
	if not ok then
		return nil, nil
	end

	-- Validate workspace
	workspace = workspace or vim.fn.expand("%:p:h")
	if workspace == "" then
		workspace = vim.fn.getcwd()
	end

	-- Check cache
	local cached = M._cache[workspace]
	if is_cache_valid(cached) then
		return cached.python_path, cached.venv_dir
	end

	-- Search upward from workspace
	local current_dir = workspace
	local home = vim.fn.expand("~")
	local depth = 0

	while current_dir and depth < M.config.max_depth do
		-- Stop at home or root
		if current_dir == home or current_dir == "/" or current_dir:match("^%a:[\\/]?$") then
			break
		end

		local python_path, venv_dir = search_venv_in_directory(Path, current_dir)
		if python_path then
			M._cache[workspace] = {
				python_path = python_path,
				venv_dir = venv_dir,
				timestamp = os.time(),
			}
			return python_path, venv_dir
		end

		-- Move to parent
		current_dir = vim.fn.fnamemodify(current_dir, ":h")
		if current_dir == "." then
			break
		end
		depth = depth + 1
	end

	-- Check VIRTUAL_ENV
	local venv_env = os.getenv("VIRTUAL_ENV")
	if venv_env then
		local python_path = find_python_in_venv(Path, venv_env)
		if python_path then
			M._cache[workspace] = {
				python_path = python_path,
				venv_dir = venv_env,
				timestamp = os.time(),
			}
			return python_path, venv_env
		end
	end

	-- Fallback to system Python
	local system_python = vim.g.python3_host_prog or vim.fn.exepath("python3") or vim.fn.exepath("python")
	if system_python and system_python ~= "" then
		return system_python, nil
	end

	return nil, nil
end

--- Clear the cache
M.clear_cache = function()
	M._cache = {}
end

return M
