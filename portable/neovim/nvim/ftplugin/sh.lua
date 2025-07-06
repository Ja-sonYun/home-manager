require("modules.utils").set_buffer_opts({ width = 2, is_code = true })

require("modules.formatter").register("sh", "shfmt -i 4 -w %")
