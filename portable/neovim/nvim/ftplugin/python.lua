require("modules.utils").set_buffer_opts({ width = 4, is_code = true })

local python_executable, python_dir = require("modules.resolver").get_python_path()

require("modules.formatter").register("python", function()
	if python_dir == nil then
		return {
			"black %",
			"isort %",
		}
	end

	local piplist = vim.fn.system(python_executable .. " -m pip list --format=freeze")
	if piplist:find("pysen") then
		local pysen = "PYSEN_IGNORE_GIT=1 " .. python_executable .. " -m pysen "
		return {
			pysen .. "run_files format %",
		}
	elseif piplist:find("ruff") then
		local ruff = python_executable .. " -m ruff "
		return {
			ruff .. "format %",
		}
	elseif piplist:find("isort") and piplist:find("black") then
		local isort = python_executable .. " -m isort "
		local black = python_executable .. " -m black "
		return {
			isort .. "%",
			black .. "%",
		}
	else
		return {
			"isort %",
			"black %",
		}
	end
end, { dir = python_dir, run_in_cwd = true })

vim.keymap.set("n", "qp", ":Shell " .. python_executable .. " %<CR>", { buffer = true, nowait = true })
