-- FROM: https://github.com/dpayne/CodeGPT.nvim/blob/master/lua/codegpt/utils.lua

M = {}

function M.get_filetype()
	local bufnr = vim.api.nvim_get_current_buf()
	return vim.api.nvim_buf_get_option(bufnr, "filetype")
end

function M.get_visual_selection()
	local bufnr = vim.api.nvim_get_current_buf()

	local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
	local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")

	if start_pos[1] == end_pos[1] and start_pos[2] == end_pos[2] then
		return 0, 0, 0, 0
	end

	local start_row = start_pos[1] - 1
	local start_col = start_pos[2]

	local end_row = end_pos[1] - 1
	local end_col = end_pos[2] + 1

	if vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, true)[1] == nil then
		return 0, 0, 0, 0
	end

	local start_line_length = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, true)[1]:len()
	start_col = math.min(start_col, start_line_length)

	local end_line_length = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, true)[1]:len()
	end_col = math.min(end_col, end_line_length)

	return start_row, start_col, end_row, end_col
end

function M.get_selected_lines()
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = M.get_visual_selection()
	local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
	return table.concat(lines, "\n")
end

function M.insert_lines(lines)
	local bufnr = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(bufnr, line, line, false, lines)
	vim.api.nvim_win_set_cursor(0, { line + #lines, 0 })
end

function M.replace_lines(lines, bufnr, start_row, start_col, end_row, end_col)
	vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, lines)
end

local function get_code_block(lines2)
	local code_block = {}
	local in_code_block = false
	for _, line in ipairs(lines2) do
		if line:match("^```") then
			in_code_block = not in_code_block
		elseif in_code_block then
			table.insert(code_block, line)
		end
	end
	return code_block
end

local function contains_code_block(lines2)
	for _, line in ipairs(lines2) do
		if line:match("^```") then
			return true
		end
	end
	return false
end

function M.trim_to_code_block(lines)
	if contains_code_block(lines) then
		return get_code_block(lines)
	end
	return lines
end

function M.parse_lines(response_text)
	if vim.g["codegpt_write_response_to_err_log"] then
		vim.api.nvim_err_write("ChatGPT response: \n" .. response_text .. "\n")
	end

	return vim.fn.split(response_text, "\n")
end

function M.fix_indentation(bufnr, start_row, end_row, new_lines)
	local original_lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, true)
	local min_indentation = math.huge
	local original_identation = ""

	-- Find the minimum indentation of any line in original_lines
	for _, line in ipairs(original_lines) do
		local indentation = string.match(line, "^%s*")
		if #indentation < min_indentation then
			min_indentation = #indentation
			original_identation = indentation
		end
	end

	-- Change the existing lines in new_lines by adding the old identation
	for i, line in ipairs(new_lines) do
		new_lines[i] = original_identation .. line
	end
end

---------------------

--- Prints a table or string
--- @param opts table
--- @return nil
M.set_buffer_opts = function(opts)
	local width = opts.width or 2
	if width <= 0 then
		width = vim.bo.tabstop
		if width <= 0 then
			width = 2
		end
	end

	vim.opt_local.shiftwidth = width
	vim.opt_local.tabstop = width
	vim.opt_local.expandtab = true
	vim.opt_local.listchars:append({
		tab = "> ",
		leadmultispace = "." .. string.rep(" ", width - 1),
	})
	vim.b.is_code = opts.is_code or false
end

--- Execute a command when the directory of the current buffer changes
--- @param filetype table
--- @param func function
M.on_buffer_change = function(filetype, func)
	local group = vim.api.nvim_create_augroup("on_buffer_change", { clear = true })
	vim.api.nvim_create_autocmd("BufLeave", {
		group = group,
		pattern = filetype,
		callback = function()
			M.last_dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
		end,
	})
	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function()
			local current_dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
			if M.last_dir and M.last_dir ~= current_dir then
				vim.notify("Directory changed from " .. M.last_dir .. " to " .. current_dir)
				func(M.last_dir, current_dir)
			end
		end,
	})
end

M.uuid = function()
	local random = math.random
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
		return string.format("%x", v)
	end)
end

return M
