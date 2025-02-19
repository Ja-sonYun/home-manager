if require('modules.plugin').mark_as_loaded('copilot') then
  return
end

vim.keymap.set('i', '<C-s>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
  ['*'] = true,
  Avante = false,
  AvanteInput = false,
}
