require("modules.util").set_buffer_opts({ width = 2, is_code = true })

require("language_server.nix").nil_ls()

require("modules.formatter").register_formatter(function()
	return { "nixfmt %" }
end)
