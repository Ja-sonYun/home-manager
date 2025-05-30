require("modules.utils").set_buffer_opts({ width = 2 })

require("modules.formatter").register_formatter(function()
  return { 'prettier --write %' }
end)
