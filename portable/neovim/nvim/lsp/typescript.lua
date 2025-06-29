return {
	cmd = { "typescript-language-server", "--stdio" },
	root_markers = {
		"tsconfig.json",
		"jsconfig.json",
		"package.json",
		"package-lock.json",
		"yarn.lock",
		"pnpm-lock.yaml",
		"node_modules",
	},
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	settings = {
		typescript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
			},
		},
	},
}
