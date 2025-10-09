--- @return table
local function split_paths(s)
	local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
	local t = {}
	for p in (s or ""):gmatch("[^" .. sep .. "]+") do
		table.insert(t, p)
	end
	return t
end

local lib = split_paths(os.getenv("LUA_LS_LIB"))

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
				library = vim.list_extend({
					vim.env.VIMRUNTIME,
				}, lib),
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
