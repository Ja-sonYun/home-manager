vim.opt_local.number = false
vim.opt_local.cursorline = true
vim.opt_local.statusline = '%n %f%=%L lines'

vim.keymap.set('n', 'q', ':q<CR>', { buffer = true, nowait = true })
vim.keymap.set('n', '<C-c>', ':q<CR>', { buffer = true, nowait = true })
vim.keymap.set('n', 'l', '<CR>:wincmd p<CR>', { buffer = true, nowait = true })

vim.cmd('wincmd J')
vim.cmd('vertical resize')
vim.cmd('horizontal resize 10')
