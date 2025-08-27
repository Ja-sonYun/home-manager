vim.keymap.set("n", "q", ":q<CR>", { buffer = true, nowait = true })
vim.keymap.set("n", "<C-c>", ":q<CR>", { buffer = true, nowait = true })

vim.opt.listchars = {
	tab = ". ",
	extends = "❯",
	precedes = "❮",
	nbsp = " ",
	trail = " ",
	leadmultispace = "| ",
}
