vim.keymap.set('n', '<C-c>', ':q!<cr>', { buffer = true, nowait = true })
vim.keymap.set('n', 'q', ':q!<cr>', { buffer = true, nowait = true })

vim.opt_local.bufhidden = 'wipe'
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.cursorline = true
