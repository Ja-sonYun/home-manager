require("modules.utils").set_buffer_opts({ width = 2 })

require("modules.formatter").register("markdown", "prettier --write %")
