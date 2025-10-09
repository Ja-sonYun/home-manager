local M = {}

M._cache = {}

M.config = {
	venv_patterns = { ".venv", "venv", "env", ".env" },
	python_names = { "python3", "python" },
	max_depth = 12,
	cache_timeout = 300, -- seconds
}

--- @return number
local function now()
	return os.time()
end

--- @param e table|nil
--- @return boolean|nil
local function cache_ok(e)
	return e and (now() - e.timestamp) < M.config.cache_timeout
end

--- @param path string
--- @return string|nil
local function read_first_line(path)
	local ok, lines = pcall(vim.fn.readfile, path, "", 1)
	if ok and type(lines) == "table" and lines[1] and lines[1] ~= "" then
		return lines[1]
	end
	return nil
end

--- @param venv_dir string
--- @return string|nil
local function find_python_in_venv(venv_dir)
	if not venv_dir or vim.fn.isdirectory(venv_dir) == 0 then
		return nil
	end
	for _, sub in ipairs({ "bin", "Scripts" }) do
		local d = vim.fs.joinpath(venv_dir, sub)
		if vim.fn.isdirectory(d) == 1 then
			for _, n in ipairs(M.config.python_names) do
				local p = vim.fs.joinpath(d, n)
				if vim.fn.filereadable(p) == 1 then
					return vim.fs.normalize(p)
				end
				local exe = vim.fs.joinpath(d, n .. ".exe")
				if vim.fn.filereadable(exe) == 1 then
					return vim.fs.normalize(exe)
				end
			end
		end
	end
	return nil
end

--- @param dir string
--- @return string|nil, string|nil
local function search_venv_in_directory(dir)
	local pyvenv_file = vim.fs.joinpath(dir, ".pyvenv")
	if vim.fn.filereadable(pyvenv_file) == 1 then
		local first = read_first_line(pyvenv_file)
		if first then
			local p = first
			if not vim.fs.dirname(first):match("^/") then
				p = vim.fs.joinpath(dir, first)
			end
			if vim.fn.filereadable(p) == 1 then
				return vim.fs.normalize(p), vim.fs.normalize(dir)
			end
		end
	end

	for _, name in ipairs(M.config.venv_patterns) do
		local venv = vim.fs.joinpath(dir, name)
		if vim.fn.isdirectory(venv) == 1 then
			local py = find_python_in_venv(venv)
			if py then
				return py, vim.fs.normalize(venv)
			end
			local cfg = vim.fs.joinpath(venv, "pyvenv.cfg")
			if vim.fn.filereadable(cfg) == 1 then
				local py2 = find_python_in_venv(venv)
				if py2 then
					return py2, vim.fs.normalize(venv)
				end
			end
		end
	end

	return nil, nil
end

--- @param cwd_or_file string|nil
--- @return string|nil, string|nil
M.get_python_path = function(cwd_or_file)
	local raw = vim.fs.normalize(cwd_or_file or vim.fn.getcwd())

	local start_path = vim.fn.filereadable(raw) == 1 and vim.fs.dirname(raw) or raw
	local key = start_path

	local cached = M._cache[key]
	if cache_ok(cached) then
		return cached.python_path, cached.venv_dir
	end

	local home = vim.fs.normalize("~")
	local cur = start_path
	local depth = 0

	while cur and depth <= M.config.max_depth do
		local py, venv = search_venv_in_directory(cur)
		if py then
			M._cache[key] = { python_path = py, venv_dir = venv, timestamp = now() }
			return py, venv
		end

		if cur == "/" or cur == home then
			break
		end

		local parent = vim.fs.dirname(cur)
		if parent == cur or parent == "." then
			break
		end
		cur = parent
		depth = depth + 1
	end

	local venv_env = os.getenv("VIRTUAL_ENV")
	if venv_env and venv_env ~= "" then
		local venv_path = vim.fs.normalize(venv_env)
		local py = find_python_in_venv(venv_path)
		if py then
			M._cache[key] = { python_path = py, venv_dir = venv_path, timestamp = now() }
			return py, venv_path
		end
	end

	local sys = vim.g.python3_host_prog or vim.fn.exepath("python3") or vim.fn.exepath("python")
	if sys and sys ~= "" then
		return sys, nil
	end

	return nil, nil
end

M.clear_cache = function()
	M._cache = {}
end

return M
