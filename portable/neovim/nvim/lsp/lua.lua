return {
	cmd = { "lua-language-server" },
	root_markers = {
		"lua-language-server.json",
		".git",
		".luarc.json",
	},
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global, etc.
				globals = {
					"vim",
					"describe",
					"it",
					"assert",
					"stub",
				},
				disable = {
					"duplicate-set-field",
				},
			},
			workspace = {
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
			hint = { -- inlay hints (supported in Neovim >= 0.10)
				enable = true,
			},
		},
	},
}
