if require('modules.plugin').mark_as_loaded('tagbar') then
    return
end

vim.keymap.set('n', '<leader>t', ':TagbarToggle<CR>')
