require('modules.util').set_buffer_opts { width = 2, is_code = true }

require('language_server.terraform').terraform_ls()

require('modules.formatter').register_formatter(function()
  return { 'terraform_fmt %' }
end)
