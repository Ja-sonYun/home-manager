require("modules.util").set_buffer_opts({ width = 2, is_code = true })

vim.lsp.enable("nix")

require("modules.formatter").register_formatter(function()
	return { "nixfmt %" }
end)
