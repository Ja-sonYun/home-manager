require('modules.util').set_buffer_opts { width = 2, is_code = true }

require('language_server.cxx').ccls()

require('modules.formatter').register_formatter(function()
  return { 'clang-format -i %' }
end)
