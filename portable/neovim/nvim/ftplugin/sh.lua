require("modules.util").set_buffer_opts({ width = 2, is_code = true })

vim.lsp.enable("sh")

require("modules.formatter").register_formatter(function()
	return { "shfmt -i 4 -w %" }
end)
