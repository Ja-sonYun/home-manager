require("modules.util").set_buffer_opts({ width = 4, is_code = true })

require("modules.formatter").register_formatter(function()
	return { "gofmt %" }
end)
