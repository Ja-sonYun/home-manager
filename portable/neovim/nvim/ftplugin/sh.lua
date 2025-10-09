require("modules.utils").set_buffer_opts({ width = 2, is_code = true })

require("formatter").register("sh", "shfmt -i 4 -w %")
