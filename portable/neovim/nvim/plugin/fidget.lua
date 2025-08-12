if require("modules.plugin").mark_as_loaded("fidget") then
	return
end

require("fidget").setup({
	notification = {
		poll_rate = 10, -- How frequently to update and render notifications
		filter = vim.log.levels.DEBUG, -- Minimum notifications level
		history_size = 128, -- Number of removed messages to retain in history
		override_vim_notify = true, -- Automatically override vim.notify() with Fidget
		-- How to configure notification groups when instantiated
		configs = {
			default = {
				name = "-----------",
				icon = "***",
				ttl = 6,
				group_style = "Title",
				icon_style = "Special",
				annote_style = "Question",
				debug_style = "Comment",
				info_style = "Question",
				warn_style = "WarningMsg",
				error_style = "ErrorMsg",
				debug_annote = "DEBUG",
				info_annote = "INFO",
				warn_annote = "WARN",
				error_annote = "ERROR",
				update_hook = function(item)
					require("fidget.notification").set_content_key(item)
				end,
			},
		},

		-- Options related to how notifications are rendered as text
		view = {
			stack_upwards = true, -- Display notification items from bottom to top
			icon_separator = " ", -- Separator between group name and icon
			group_separator = "-----", -- Separator between notification groups
			-- Highlight group used for group separator
			group_separator_hl = "Comment",
			-- How to render notification messages
			render_message = function(msg, cnt)
				return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
			end,
		},

		-- Options related to the notification window and buffer
		window = {
			normal_hl = "Comment", -- Base highlight group in the notification window
			winblend = 100, -- Background color opacity in the notification window
			border = "none", -- Border around the notification window
			zindex = 45, -- Stacking priority of the notification window
			max_width = 0, -- Maximum width of the notification window
			max_height = 0, -- Maximum height of the notification window
			x_padding = 1, -- Padding from right edge of window boundary
			y_padding = 0, -- Padding from bottom edge of window boundary
			align = "bottom", -- How to align the notification window
			relative = "editor", -- What the notification window position is relative to
		},
	},
})
