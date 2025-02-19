if require('modules.plugin').mark_as_loaded('commands') then
  return
end

-- delete current buffer
vim.api.nvim_create_user_command('Q', 'bd % <CR>', {})
