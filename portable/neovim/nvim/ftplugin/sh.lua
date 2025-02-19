require('modules.util').set_buffer_opts { width = 2, is_code = true }

require('language_server.sh').bash_language_server()

require('modules.formatter').register_formatter(function()
  return { 'shfmt -i 4 -w %' }
end)
