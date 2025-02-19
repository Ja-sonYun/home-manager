if require('modules.plugin').mark_as_loaded('harpoon') then
  return
end

local harpoon = require('harpoon')

harpoon:setup()

vim.keymap.set('n', 'ma', function()
  harpoon:list():add()
end)
vim.keymap.set('n', 'mm', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set('n', 'mp', function()
  harpoon:list():prev()
end)
vim.keymap.set('n', 'mn', function()
  harpoon:list():next()
end)
