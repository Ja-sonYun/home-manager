vim.env.FZF_DEFAULT_OPTS = ((vim.env.FZF_DEFAULT_OPTS or "") .. " --multi --bind ctrl-s:select-all,ctrl-d:deselect-all")

vim.g.fzf_layout = { down = "20%" }

vim.keymap.set("n", "<space>f", ":Files<CR>")
vim.keymap.set("n", "<space>r", ":Rg<CR>")
vim.keymap.set("n", "<space>b", ":Buffers<CR>")

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("Fzf", { clear = true }),
	pattern = "fzf",
	callback = function()
		vim.keymap.set("n", "q", ":q<CR>", { buffer = true, nowait = true })
		vim.keymap.set("n", "<C-c>", ":q<CR>", { buffer = true, nowait = true })
	end,
})

vim.cmd([[
autocmd! FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
]])
