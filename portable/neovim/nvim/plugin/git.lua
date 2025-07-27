if require("modules.plugin").mark_as_loaded("git") then
	return
end

vim.cmd([[
autocmd! FileType fugitive resize 20
]])

vim.keymap.set("n", "<leader>gg", ":Git<CR>")
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>")
vim.keymap.set("n", "<leader>gd", ":Gdiffsplit ")
vim.keymap.set("n", "<leader>gl", ":Git log<CR>")
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>")
