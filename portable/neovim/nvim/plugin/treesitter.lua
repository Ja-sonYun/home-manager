local configs = require("nvim-treesitter.configs")
vim.g.skip_ts_context_comment_string_module = true

---@diagnostic disable-next-line: missing-fields
configs.setup({
	-- ensure_installed = 'all',
	-- auto_install = false, -- Do not automatically install missing parsers when entering buffer
	highlight = {
		enable = true,
		disable = function(_, buf)
			local max_filesize = 100 * 1024 -- 100 KiB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
			local filetype = vim.bo[buf].filetype

			-- Disable treesitter highlighting for Dockerfiles
			-- https://github.com/camdencheek/tree-sitter-dockerfile/issues/65
			if filetype == "dockerfile" then
				return true
			end
		end,
	},
	textobjects = {
		-- select = {
		--   enable = true,
		--   -- Automatically jump forward to textobject, similar to targets.vim
		--   lookahead = true,
		--   keymaps = {
		--     ['af'] = '@function.outer',
		--     ['if'] = '@function.inner',
		--     ['ac'] = '@class.outer',
		--     ['ic'] = '@class.inner',
		--     ['aC'] = '@call.outer',
		--     ['iC'] = '@call.inner',
		--     ['a#'] = '@comment.outer',
		--     ['i#'] = '@comment.outer',
		--     ['ai'] = '@conditional.outer',
		--     ['ii'] = '@conditional.outer',
		--     ['al'] = '@loop.outer',
		--     ['il'] = '@loop.inner',
		--     ['aP'] = '@parameter.outer',
		--     ['iP'] = '@parameter.inner',
		--   },
		--   selection_modes = {
		--     ['@parameter.outer'] = 'v', -- charwise
		--     ['@function.outer'] = 'V', -- linewise
		--     ['@class.outer'] = '<c-v>', -- blockwise
		--   },
		-- },
		-- swap = {
		--   enable = true,
		--   swap_next = {
		--     ['<leader>a'] = '@parameter.inner',
		--   },
		--   swap_previous = {
		--     ['<leader>A'] = '@parameter.inner',
		--   },
		-- },
		-- move = {
		--   enable = true,
		--   set_jumps = true, -- whether to set jumps in the jumplist
		--   goto_next_start = {
		--     [']m'] = '@function.outer',
		--     [']P'] = '@parameter.outer',
		--   },
		--   goto_next_end = {
		--     [']m'] = '@function.outer',
		--     [']P'] = '@parameter.outer',
		--   },
		--   goto_previous_start = {
		--     ['[m'] = '@function.outer',
		--     ['[P'] = '@parameter.outer',
		--   },
		--   goto_previous_end = {
		--     ['[m'] = '@function.outer',
		--     ['[P'] = '@parameter.outer',
		--   },
		-- },
		-- nsp_interop = {
		--   enable = true,
		--   peek_definition_code = {
		--     ['df'] = '@function.outer',
		--     ['dF'] = '@class.outer',
		--   },
		-- },
	},
})

require("ts_context_commentstring").setup()

-- Tree-sitter based folding
-- vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Default colorscheme
vim.api.nvim_set_hl(0, "Structure", { ctermfg = 130 })
vim.api.nvim_set_hl(0, "Number", { ctermfg = 196 })

-- Treesitter
vim.api.nvim_set_hl(0, "@constant", { ctermfg = 160 })
vim.api.nvim_set_hl(0, "@attribute", { ctermfg = 99 })
vim.api.nvim_set_hl(0, "@variable.builtin", { ctermfg = 69 })
vim.api.nvim_set_hl(0, "@variable.parameter", { ctermfg = 44 })
vim.api.nvim_set_hl(0, "@type.builtin", { ctermfg = 34 })
vim.api.nvim_set_hl(0, "@function.call", { ctermfg = 111 })
vim.api.nvim_set_hl(0, "@function.method.call", { ctermfg = 111 })
vim.api.nvim_set_hl(0, "@lsp.type.interface", { ctermfg = 2 })
vim.api.nvim_set_hl(0, "@lsp.type.namespace", { ctermfg = 40 })
vim.api.nvim_set_hl(0, "@lsp.type.function", { ctermfg = 111 })
