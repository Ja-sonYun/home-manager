if require('modules.plugin').mark_as_loaded('spider') then
  return
end

require('spider').setup {
  skipInsignificantPunctuation = true,
}

vim.keymap.set({ 'n', 'o', 'x' }, 'W', "<cmd>lua require('spider').motion('w')<CR>", { desc = 'Spider-w' })
vim.keymap.set({ 'n', 'o', 'x' }, 'B', "<cmd>lua require('spider').motion('b')<CR>", { desc = 'Spider-b' })
vim.keymap.set({ 'n', 'o', 'x' }, 'E', "<cmd>lua require('spider').motion('e')<CR>", { desc = 'Spider-e' })
