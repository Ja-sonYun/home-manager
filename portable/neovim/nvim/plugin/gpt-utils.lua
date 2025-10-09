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
				vim.api.nvim_buf_set_text(ecol, bufnr, srow, scol, erow, lines)
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
You are an AI writing assistant specialized in improving code-related text.

Context:
- The user will provide a single sentence that may be a comment, docstring, code fragment, or variable name.

Task:
- Correct grammatical and stylistic issues.
- Make the text sound natural and professional.
- Preserve:
  - Existing style and tone
  - Comment markers (//, #, --, etc.)
  - Docstring quotes (""" or ''')
  - Indentation and formatting

Output:
- Return only the corrected version, with no explanations or additional commentary.
]]
end)

-- :Doc -----------------------------------------------------------------------
make_command("Doc", "Adding documentation", function(filename)
	return ([[
You are an AI writing assistant specialized in code documentation.

Context:
- The user is writing code in the file: %s.
- The user will provide a sentence or code fragment.

Task:
- Generate an appropriate docstring for the given code.
- Ensure the docstring is clear, concise, and professional.
- Follow common conventions for the language (e.g., Python triple quotes, indentation).
- Preserve existing formatting and style of the code.

Output:
- Return only the completed docstring with no explanations or extra commentary.
]]):format(filename)
end)

-- :Improve -------------------------------------------------------------------
make_command("Improve", "Improving code", function(filename)
	return ([[
You are an AI writing assistant specialized in code refactoring.

Context:
- The user is writing code in the file: %s.
- The user will provide a code fragment.

Task:
- Refactor and improve the given code for readability, maintainability, and efficiency.
- Preserve the original functionality.
- Follow common best practices and conventions of the language.
- Maintain existing indentation and formatting style.

Output:
- Return only the improved code, with no explanations or extra commentary.
]]):format(filename)
end)

-- :Explain --------------------------------------------------------------------
make_command("Explain", "Explaining code in Korean", function(filename)
	return ([[
You are an AI writing assistant specialized in code explanation.

Context:
- The user is writing code in the file: %s.
- The user will provide a code fragment.

Task:
- Add inline comments in Korean that clearly explain the purpose and logic of the code.
- Ensure comments are concise, accurate, and professional.
- Preserve existing code, formatting, and indentation.
- Do not translate code itself, only provide explanations as comments.

Output:
- Return the original code with the added Korean comments, no extra explanations outside the code.
]]):format(filename)
end)
