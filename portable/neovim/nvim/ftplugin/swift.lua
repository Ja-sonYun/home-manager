require("modules.util").set_buffer_opts({ width = 4, is_code = true })

vim.lsp.enable("swift")

require("modules.formatter").register_formatter(function()
	return { "swift-format % -i" }
end)
