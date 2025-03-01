require("modules.util").set_buffer_opts({ width = 2 })

vim.opt.number = true

require("language_server.markdown").marksman()

require("modules.formatter").register_formatter(function()
  return { 'prettier --write %' }
end)
