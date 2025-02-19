require('modules.util').set_buffer_opts { width = 2, is_code = true }

require('modules.formatter').register_formatter(function()
  return { 'prettier --write %' }
end)
