-----------------------------------------------------------
-- NetRW
-----------------------------------------------------------
vim.g.netrw_preview = 1
vim.g.netrw_use_errorwindow = 0
vim.g.netrw_winsize = 30
vim.g.netrw_fastbrowse = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_liststyle = 0
vim.g.netrw_special_syntax = 1

vim.keymap.set("n", "<leader>f", function()
	if vim.bo.filetype ~= "netrw" then
		vim.cmd.Explore()
	end
end, { desc = "Open netrw" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("NetrwAuto", { clear = true }),
	pattern = "netrw",
	callback = function()
		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer = 0,
			callback = function()
				if vim.fn.line(".") < 8 then
					vim.fn.cursor(8, 1)
				end
			end,
		})

		vim.schedule(function()
			local cur_file = vim.fn.expand("#:t") -- previous buffer filename
			if cur_file == "" then
				return
			end
			local start_line = 8 -- first entry line in netrw
			local last_line = vim.api.nvim_buf_line_count(0)
			local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, last_line, false)
			for i, s in ipairs(lines) do
				if vim.fn.trim(s) == cur_file then
					vim.api.nvim_win_set_cursor(0, { start_line + i - 1, 0 })
					break
				end
			end
		end)
	end,
})
