return {
	cmd = { "xcrun", "sourcekit-lsp" },
	cmd_env = { DEVELOPER_DIR = "/Applications/Xcode.app/Contents/Developer", SDKROOT = "" },
	root_markers = {
		"Package.swift",
		".xcodeproj",
		".xcworkspace",
	},
	filetypes = { "swift" },
}
