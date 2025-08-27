require("modules.utils").set_buffer_opts({ width = 4, is_code = true })

require("modules.formatter").register("rust", "rustfmt --edition 2021 %")
