require('modules.util').set_buffer_opts { width = 2, is_code = true }

vim.bo.comments = ':---,:--'

require('language_server.lua').lua_language_server()

require('modules.formatter').register_formatter(function()
  return { 'stylua %' }
end)
