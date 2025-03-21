require("modules.util").set_buffer_opts({ width = 2, is_code = true })

require("language_server.ruby").ruby_lsp()

require("modules.formatter").register_formatter(function()
	return { "rufo -x %" }
end)
