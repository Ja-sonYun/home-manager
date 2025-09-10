if require("modules.plugin").mark_as_loaded("netrw") then
	return
end

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
	local cur_file = vim.fn.expand("%:t")
	vim.cmd.Explore()

	local starting_line = 10
	local lines = vim.api.nvim_buf_get_lines(0, starting_line, -1, false)
	for i, file in ipairs(lines) do
		if file == cur_file then
			vim.api.nvim_win_set_cursor(0, { i + starting_line, 0 })
			break
		end
	end
end)
