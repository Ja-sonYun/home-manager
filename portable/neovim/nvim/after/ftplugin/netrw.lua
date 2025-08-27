vim.opt_local.signcolumn = "no"

vim.opt_local.bufhidden = "wipe"
vim.opt_local.number = false
vim.opt_local.relativenumber = false

vim.opt_local.listchars.multispace = "\\ "

-- Keymaps
vim.cmd([[
nmap <buffer> l <CR>
nmap <buffer> h -
nmap <buffer> a %
nmap <buffer> m R
nmap <buffer> r :e . <bar> echo 'Reloaded.'<cr>
nmap <buffer> t <nop>
nmap <buffer> v v$h
]])

vim.keymap.set("n", "q", ":Rex<cr>", { buffer = true, nowait = true, silent = true, noremap = true })
vim.keymap.set("n", "<C-c>", ":Rex<cr>", { buffer = true, nowait = true, silent = true, noremap = true })
vim.keymap.set("n", "<leader>f", ":Rex<cr>", { buffer = true, nowait = true, silent = true, noremap = true })

vim.keymap.set("n", "<c-h>", ":TmuxNavigateLeft<cr>", { buffer = true, nowait = true, silent = true, noremap = true })
vim.keymap.set("n", "<c-j>", ":TmuxNavigateDown<cr>", { buffer = true, nowait = true, silent = true, noremap = true })
vim.keymap.set("n", "<c-k>", ":TmuxNavigateUp<cr>", { buffer = true, nowait = true, silent = true, noremap = true })
vim.keymap.set("n", "<c-l>", ":TmuxNavigateRight<cr>", { buffer = true, nowait = true, silent = true, noremap = true })

-- Highlight
vim.api.nvim_set_hl(0, "Directory", { ctermfg = 6 })
