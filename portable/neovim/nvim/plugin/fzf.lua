if require('modules.plugin').mark_as_loaded('fzf') then
  return
end

vim.g.fzf_layout = { down = '20%' }

vim.keymap.set('n', '<space>f', ':Files<CR>')
vim.keymap.set('n', '<space>r', ':Rg<CR>')
vim.keymap.set('n', 'qb', ':Buffer<CR>')

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('Fzf', { clear = true }),
  pattern = 'fzf',
  callback = function()
    vim.keymap.set('n', 'q', ':q<CR>', { buffer = true, nowait = true })
    vim.keymap.set('n', '<C-c>', ':q<CR>', { buffer = true, nowait = true })
  end,
})
