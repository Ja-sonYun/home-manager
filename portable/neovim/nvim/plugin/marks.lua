if require("modules.plugin").mark_as_loaded("marks") then
	return
end

require("marks").setup({
	-- whether to map keybinds or not. default true
	default_mappings = false,
	-- which builtin marks to show. default {}
	builtin_marks = { ".", "^" },
	-- whether movements cycle back to the beginning/end of buffer. default true
	cyclic = true,
	-- whether the shada file is updated after modifying uppercase marks. default false
	force_write_shada = false,
	-- how often (in ms) to redraw signs/recompute mark positions.
	-- higher values will have better performance but may cause visual lag,
	-- while lower values may cause performance penalties. default 150.
	refresh_interval = 250,
	-- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
	-- marks, and bookmarks.
	-- can be either a table with all/none of the keys, or a single number, in which case
	-- the priority applies to all marks.
	-- default 10.
	sign_priority = { lower = 11, upper = 15, builtin = 8, bookmark = 20 },
	-- disables mark tracking for specific filetypes. default {}
	excluded_filetypes = {},
	-- disables mark tracking for specific buftypes. default {}
	excluded_buftypes = {},
	-- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
	-- sign/virttext. Bookmarks can be used to group together positions and quickly move
	-- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
	-- default virt_text is "".
	mappings = {
		set_next = "''",
		delete_line = "dm-",
		delete_buf = "dm<space>",
		next = "]m",
		prev = "[m",
		preview = "m<space>",
		set = "'",
		delete = "dm",
	},
})

vim.keymap.set("n", "m", "'")
vim.keymap.set("n", "mm", ":Marks<CR>")

vim.api.nvim_set_hl(0, "MarkSignHL", { ctermfg = 2, ctermbg = 5, bold = true })
