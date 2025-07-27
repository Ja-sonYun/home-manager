require("modules.utils").set_buffer_opts({ width = 2 })

-- if vim.bo.buftype ~= "nofile" then
-- 	vim.opt_local.number = true
-- end

require("modules.formatter").register("markdown", "prettier --write %")
