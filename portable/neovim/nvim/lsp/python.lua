return {
	cmd = { "pyright-langserver", "--stdio" },
	root_markers = {
		"flake.nix",
		"default.nix",
		"shell.nix",
		"pyproject.toml",
		"setup.py",
		"requirements.txt",
		"poetry.lock",
		".git",
		".gitignore",
		".gitmodules",
		".venv",
	},
	filetypes = { "python" },
	settings = {
		python = {
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
	before_init = function(_, config)
		local python_executable, python_dir = require("modules.resolver").get_python_path()
		config.settings.python.pythonPath = python_executable
	end,
}
