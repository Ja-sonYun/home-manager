require("macroedit").setup()

vim.keymap.set("n", "q", "<Nop>", { desc = "No operation" })
vim.keymap.set("n", "@", "<Nop>", { desc = "No operation" })
vim.keymap.set("n", "@@", "q", { desc = "Start recording macro" })
vim.keymap.set("n", "qq", "@", { desc = "Execute macro" })
vim.keymap.set("n", "Q", ":MacroEdit<CR>", { desc = "Edit macro" })
