require("modules.utils").set_buffer_opts({ width = 4, is_code = true })

local resolver = require("modules.pylib")
local python_executable, python_dir = resolver.get_python_path()

local function has_module(mod)
	local cmd = {
		python_executable,
		"-c",
		string.format("import importlib.util,sys;sys.exit(0 if importlib.util.find_spec('%s') else 1)", mod),
	}
	return (vim.system(cmd, { timeout = 1500 }):wait().code == 0)
end

require("formatter").register("python", function()
	if python_dir == nil then
		if vim.fn.executable("pysen") == 1 then
			return { { "pysen", "run_files", "format", "%" } }
		elseif vim.fn.executable("ruff") == 1 then
			return { { "ruff", "format", "%" } }
		elseif vim.fn.executable("black") == 1 and vim.fn.executable("isort") == 1 then
			return {
				{ "isort", "%" },
				{ "black", "%" },
			}
		else
			return {
				{ "isort", "%" },
				{ "black", "%" },
			}
		end
	end

	if has_module("pysen") then
		return { { python_executable, "-m", "pysen", "run_files", "format", "%" } }
	elseif has_module("ruff") then
		return { { python_executable, "-m", "ruff", "format", "%" } }
	elseif has_module("isort") and has_module("black") then
		return {
			{ python_executable, "-m", "isort", "%" },
			{ python_executable, "-m", "black", "%" },
		}
	else
		return {
			{ "isort", "%" },
			{ "black", "%" },
		}
	end
end, {
	cwd = python_dir,
})

vim.keymap.set("n", "qp", ":Shell " .. python_executable .. " %<CR>", { buffer = true, nowait = true })
