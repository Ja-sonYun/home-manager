require("modules.util").set_buffer_opts({ width = 2, is_code = true })

vim.opt.number = true

require("language_server.markdown").marksman()

require("modules.formatter").register_formatter(function()
	return { "markdownlint-cli2 %" }
end)
