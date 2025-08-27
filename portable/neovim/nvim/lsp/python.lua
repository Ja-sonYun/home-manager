return {
	cmd = { "pyright-langserver", "--stdio" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"Pipfile",
		"Pipfile.lock",
		"requirements.txt",
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
