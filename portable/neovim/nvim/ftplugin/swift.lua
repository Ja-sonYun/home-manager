require('modules.util').set_buffer_opts { width = 4, is_code = true }

require('language_server.swift').sourcekit_lsp()

require('modules.formatter').register_formatter(function()
  return { 'swift-format % -i' }
end)
