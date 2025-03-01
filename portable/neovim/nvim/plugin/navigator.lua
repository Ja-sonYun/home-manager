if require('modules.plugin').mark_as_loaded('vim-tmux-navigator') then
  return
end

-- Check TMUX flag is set
if vim.env.TMUX == nil then
  vim.keymap.set('n', '<C-h>', '<C-w>h')
  vim.keymap.set('n', '<C-j>', '<C-w>j')
  vim.keymap.set('n', '<C-k>', '<C-w>k')
  vim.keymap.set('n', '<C-l>', '<C-w>l')
else
  vim.keymap.set('n', '<C-h>', ':TmuxNavigateLeft<CR>')
  vim.keymap.set('n', '<C-j>', ':TmuxNavigateDown<CR>')
  vim.keymap.set('n', '<C-k>', ':TmuxNavigateUp<CR>')
  vim.keymap.set('n', '<C-l>', ':TmuxNavigateRight<CR>')
end
