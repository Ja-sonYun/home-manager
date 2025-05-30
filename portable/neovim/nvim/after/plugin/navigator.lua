if require("modules.plugin").mark_as_loaded("vim-tmux-navigator") then
	return
end

-- Check TMUX flag is set
if vim.env.TMUX == nil then
	vim.keymap.set("n", "<C-h>", "<C-w>h")
	vim.keymap.set("n", "<C-j>", "<C-w>j")
	vim.keymap.set("n", "<C-k>", "<C-w>k")
	vim.keymap.set("n", "<C-l>", "<C-w>l")
	-- Terminal mappings
	vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")
	vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
	vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
	vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
	vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")
  vim.keymap.set("t", "<C-[>", "<C-\\><C-n>")
else
	vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>")
	vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>")
	vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>")
	vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>")
	-- Terminal mappings
  vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")
  vim.keymap.set("t", "<C-h>", "<C-\\><C-n><Cmd>TmuxNavigateLeft<CR>", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-j>", "<C-\\><C-n><Cmd>TmuxNavigateDown<CR>", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-k>", "<C-\\><C-n><Cmd>TmuxNavigateUp<CR>", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-l>", "<C-\\><C-n><Cmd>TmuxNavigateRight<CR>", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-[>", "<C-\\><C-n>")
end
