return {
	cmd = { "ccls" },
	root_markers = {
		".ccls",
		".ccls-cache",
		"compile_commands.json",
		"compile_flags.txt",
		"Makefile",
		"CMakeLists.txt",
		"meson.build",
	},
	filetypes = { "c", "cpp", "objc", "objcpp" },
}
