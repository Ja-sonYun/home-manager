if require("modules.plugin").mark_as_loaded("vim-tmux-navigator") then
	return
end

-- Check TMUX flag is set
if vim.env.TMUX == nil then
	vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
	vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
	vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
	vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
	-- Terminal mappings
	vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-[>", "<C-\\><C-n>", { noremap = true, silent = true })
else
	vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { noremap = true, silent = true })
	vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { noremap = true, silent = true })
	vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { noremap = true, silent = true })
	vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { noremap = true, silent = true })
	-- Terminal mappings
	vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")
	vim.keymap.set("t", "<C-h>", "<C-\\><C-n><Cmd>TmuxNavigateLeft<CR>", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-j>", "<C-\\><C-n><Cmd>TmuxNavigateDown<CR>", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-k>", "<C-\\><C-n><Cmd>TmuxNavigateUp<CR>", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-l>", "<C-\\><C-n><Cmd>TmuxNavigateRight<CR>", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-[>", "<C-\\><C-n>")
end
