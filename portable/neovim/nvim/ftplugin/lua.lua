require("modules.utils").set_buffer_opts({ width = 2, is_code = true })

vim.bo.comments = ":---,:--"

require("modules.formatter").register("lua", "stylua %")
