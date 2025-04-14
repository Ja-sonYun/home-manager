if require("modules.plugin").mark_as_loaded("rainbow-delimiters") then
	return
end

local rainbow_delimiters = require("rainbow-delimiters")

vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { ctermfg = 69 })
vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { ctermfg = 106 })
vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { ctermfg = 166 })
vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { ctermfg = 147 })

vim.g.rainbow_delimiters = {
	strategy = {
		[""] = rainbow_delimiters.strategy["global"],
		vim = rainbow_delimiters.strategy["local"],
	},
	query = {
		[""] = "rainbow-delimiters",
	},
	highlight = {
		"RainbowDelimiterOrange",
		"RainbowDelimiterGreen",
		"RainbowDelimiterBlue",
	},
}
