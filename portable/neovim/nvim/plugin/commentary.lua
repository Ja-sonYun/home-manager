if require('modules.plugin').mark_as_loaded('vim-commentary') then
  return
end

vim.api.nvim_set_keymap('v', '\\c<Space>', '<Plug>Commentary', {})
vim.api.nvim_set_keymap('n', '\\c<Space>', '<Plug>CommentaryLine', {})
