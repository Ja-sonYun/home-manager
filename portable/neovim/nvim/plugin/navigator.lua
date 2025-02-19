if require('modules.plugin').mark_as_loaded('vim-tmux-navigator') then
  return
end

vim.keymap.set('n', '<C-h>', ':TmuxNavigateLeft<CR>')
vim.keymap.set('n', '<C-j>', ':TmuxNavigateDown<CR>')
vim.keymap.set('n', '<C-k>', ':TmuxNavigateUp<CR>')
vim.keymap.set('n', '<C-l>', ':TmuxNavigateRight<CR>')
