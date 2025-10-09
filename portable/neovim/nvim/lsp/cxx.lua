return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--all-scopes-completion",
	},
	root_markers = {
		"compile_commands.json",
		"compile_flags.txt",
		"Makefile",
		"CMakeLists.txt",
		"meson.build",
	},
	filetypes = { "c", "cpp", "objc", "objcpp" },
}
