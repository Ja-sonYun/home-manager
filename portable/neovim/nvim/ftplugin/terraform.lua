require("modules.utils").set_buffer_opts({ width = 2, is_code = true })

require("formatter.lua.formatter").register("terraform", "terraform fmt %")
