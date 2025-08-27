if require("modules.plugin").mark_as_loaded("gpt-utils") then
	return
end

local uv = vim.uv or vim.loop

--- Build and register Neovim user commands that leverage GPT.
--- @param name string  Name of the :Command
--- @param status_msg string  Verb for notifications ("Fixing", "Adding doc", ...)
--- @param prompt_builder fun(filename: string): string  Returns system-prompt
local function make_command(name, status_msg, prompt_builder)
	vim.api.nvim_create_user_command(name, function()
		local utils = require("modules.utils")
		local gpt = require("modules.gpt")

		-- 1. Acquire selection ---------------------------------------------------
		local selection = utils.get_selected_lines()
		if #selection == 0 then
			vim.notify("No text selected.", vim.log.levels.WARN)
			return
		end

		local bufnr = vim.api.nvim_get_current_buf()
		local srow, scol, erow, ecol = utils.get_visual_selection()

		-- 2. Prepare callback ----------------------------------------------------
		local function apply_result(raw_text)
			local lines = vim.fn.split(raw_text, "\n")
			lines = utils.trim_to_code_block(lines)
			utils.fix_indentation(bufnr, srow, erow, lines)

			if vim.api.nvim_buf_is_valid(bufnr) then
				utils.replace_lines(lines, bufnr, srow, scol, erow, ecol)
			else
				vim.notify("Buffer is not valid anymore.", vim.log.levels.WARN)
			end
			vim.notify(status_msg .. " complete!", vim.log.levels.INFO)
		end

		-- 3. Call GPT ------------------------------------------------------------
		vim.notify(status_msg .. "...", vim.log.levels.INFO)
		local prompt = prompt_builder(vim.fn.expand("%"))
		gpt.call_api(selection, prompt, apply_result)
	end, { range = true, nargs = "*" })
end

-- :Fix -----------------------------------------------------------------------
make_command("Fix", "Fixing", function()
	return [[
User is writing code.
User will provide a sentence (comment, docstring, code fragment, or variable name).
Please correct grammatical issues to make it sound natural while preserving style, comment markers, docstring quotes, and indentation.
]]
end)

-- :Doc -----------------------------------------------------------------------
make_command("Doc", "Adding documentation", function(filename)
	return (
		"User is writing code. File name: %s.\n"
		.. "User will provide a sentence or code fragment.\n"
		.. "Please add an appropriate docstring for that code."
	):format(filename)
end)

-- :Improve -------------------------------------------------------------------
make_command("Improve", "Improving code", function(filename)
	return (
		"User is writing code. File name: %s.\n"
		.. "User will provide a code fragment.\n"
		.. "Please refactor and improve the given code."
	):format(filename)
end)
