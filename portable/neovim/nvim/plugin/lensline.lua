if require("modules.plugin").mark_as_loaded("lensline") then
	return
end

require("lensline").setup({
	profiles = {
		{
			name = "default",
			providers = {
				{
					name = "references",
					event = { "LspAttach", "BufWritePost" },
					handler = function(bufnr, func_info, provider_config, callback)
						local utils = require("lensline.utils")

						-- Use composable LSP utility
						utils.get_lsp_references(bufnr, func_info, function(references)
							if references then
								local count = #references
								if count == 0 then
									callback(nil)
									return
								end
								local icon = "&"
								callback({
									line = func_info.line,
									text = icon .. count,
								})
							else
								callback(nil)
							end
						end)
					end,
				},
				-- {
				-- 	name = "function_length",
				-- 	enabled = true,
				-- 	event = { "BufWritePost", "TextChanged" }, -- when to recalc
				-- 	handler = function(bufnr, func_info, cfg, cb)
				-- 		-- get lines of current function
				-- 		local utils = require("lensline.utils")
				-- 		local lines = utils.get_function_lines(bufnr, func_info)
				-- 		local count = math.max(0, #lines - 1) -- exclude signature
				-- 		cb({ line = func_info.line, text = string.format("L%d)", count) })
				-- 	end,
				-- },
			},
			style = {
				separator = ",",
				highlight = "CopilotSuggestion",
				prefix = "",
				placement = "inline",
				use_nerdfont = false,
			},
		},
	},
})
