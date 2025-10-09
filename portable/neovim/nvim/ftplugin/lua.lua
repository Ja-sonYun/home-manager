require("modules.utils").set_buffer_opts({ width = 2, is_code = true })

vim.bo.comments = ":---,:--"

require("formatter.lua.formatter").register("lua", "stylua %")
