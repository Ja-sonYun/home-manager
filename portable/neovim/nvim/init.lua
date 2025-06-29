local constant = require("modules.constant")

-----------------------------------------------------------
vim.g.logging_level = "info"

vim.g.loaded_perl_provider = 0 -- Disable perl provider
vim.g.loaded_ruby_provider = 0 -- Disable ruby provider
vim.g.loaded_node_provider = 0 -- Disable node provider
vim.g.did_install_default_menus = 1 -- do not load menu

-- Disable sql omni completion, it is broken.
vim.g.loaded_sql_completion = 1

vim.g.mapleader = ","

-----------------------------------------------------------
-- General
-----------------------------------------------------------
vim.opt.mouse = "" -- Disable mouse support
vim.opt.clipboard = "unnamedplus" -- Copy/paste to system clipboard
vim.opt.swapfile = false -- Don't use swapfile

vim.opt.shiftround = true
vim.opt.virtualedit = "block"

-----------------------------------------------------------
-- Ignore certain files and folders when globing
-----------------------------------------------------------
vim.opt.wildignore:append(constant.non_code)
vim.opt.wildignorecase = true

-----------------------------------------------------------
-- Backups
-----------------------------------------------------------
vim.g.backupdir = vim.fn.expand(vim.fn.stdpath("data") .. "/backup//")
vim.opt.backupdir = vim.g.backupdir
vim.opt.backupskip = constant.non_code
vim.opt.backup = true
vim.opt.backupcopy = "yes"

-- Undo
vim.opt.undofile = true -- Enable persistent undo

-----------------------------------------------------------
-- Autocomplete
-----------------------------------------------------------
vim.opt.completeopt = "menuone,noselect" -- Autocomplete options
vim.opt.pumheight = 10
vim.opt.pumblend = 0 -- transparency
vim.opt.winblend = 0 -- pseudo transparency for floating window

-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
vim.opt.number = false -- Show line number
vim.opt.showmatch = true -- Highlight matching parenthesis
vim.opt.splitkeep = "screen"

-----------------------------------------------------------
-- Folding
-----------------------------------------------------------
-- opt.foldmethod = 'marker'   -- Enable folding (default 'foldmarker')
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

-----------------------------------------------------------
-- Code
-----------------------------------------------------------
vim.opt.matchpairs:append({ "<:>", "「:」", "『:』", "【:】", "“:”", "‘:’", "《:》" })
vim.opt.splitright = true -- Vertical split to the right
vim.opt.splitbelow = true -- Horizontal split to the bottom
vim.opt.ignorecase = true -- Ignore case letters when search
vim.opt.smartcase = true -- Ignore lowercase for the whole pattern
vim.opt.linebreak = true -- Wrap on word boundary
vim.opt.termguicolors = false -- Enable 24-bit RGB colors
vim.opt.ruler = true
vim.opt.scrolloff = 3
vim.opt.jumpoptions = "stack"

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Autoindent new lines
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.list = true -- Show some invisible characters (tabs...)
vim.opt.listchars = {
	tab = ". ", -- trailing space after the symbol
	extends = "❯",
	precedes = "❮",
	nbsp = "␣",
	trail = "~",
	leadmultispace = "|   ",
}

vim.cmd([[set wildcharm=<tab>]])

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
vim.opt.hidden = true -- Enable background buffers
vim.opt.history = 100 -- Remember N lines in history
vim.opt.lazyredraw = true -- Faster scrolling
vim.opt.synmaxcol = 240 -- Max column for syntax highlight
vim.opt.updatetime = 250 -- ms to wait for trigger an event

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- Disable nvim intro
vim.opt.shortmess:append("sI")

-----------------------------------------------------------
-- DefaultTheme
-----------------------------------------------------------
vim.opt.background = "light" -- Dark background

vim.cmd([[colorscheme vim]])

-----------------------------------------------------------
-- NetRW
-----------------------------------------------------------
vim.g.netrw_preview = 1
vim.g.netrw_use_errorwindow = 0
vim.g.netrw_winsize = 30
vim.g.netrw_fastbrowse = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_liststyle = 0
vim.g.netrw_special_syntax = 1

vim.keymap.set("n", "<leader>f", function()
	local cur_file = vim.fn.expand("%:t")
	vim.cmd.Ex()

	local starting_line = 10
	local lines = vim.api.nvim_buf_get_lines(0, starting_line, -1, false)
	for i, file in ipairs(lines) do
		if file == cur_file then
			vim.api.nvim_win_set_cursor(0, { i + starting_line, 0 })
			break
		end
	end
end)

-----------------------------------------------------------
-- Macro
-----------------------------------------------------------
vim.keymap.set("n", "@", "q")
vim.keymap.set("n", "q", "@")
vim.keymap.set("n", "qq", "@@")
vim.keymap.set("n", "~", "Q")
vim.keymap.set("n", "Q", ":MacroEdit<CR>")

vim.cmd([[
  function! YankToRegister()
    exe printf('norm! ^"%sy$', b:registername)
  endfunction

  function! OpenMacroEditorWindow()
    let registername = nr2char(getchar())
    let name = 'MacroEditor'
    if bufexists(name)
      echohl WarningMsg
      echom "One macro at a time:)"
      echohl None
      let win = bufwinnr(name)
      exe printf('%d . wincmd w', win)
      return
    endif
    let height = 3
    execute height 'new ' name
    let b:registername = registername
    setlocal bufhidden=wipe noswapfile nobuflisted
    exe printf('norm! "%sp', b:registername)
    set nomodified
    augroup MacroEditor
      au!
      au BufWriteCmd <buffer> call YankToRegister()
      au BufWriteCmd <buffer> set nomodified
    augroup END
  endfunction
  command! MacroEdit call OpenMacroEditorWindow()
]])

-----------------------------------------------------------
-- Statusline
-----------------------------------------------------------
function GetScrollbar()
	local sbar_chars = { "▇", "▆", "▅", "▄", "▃", "▂", "▁" }

	local cur_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_line_count(0)

	local i = math.floor((cur_line - 1) / lines * #sbar_chars) + 1
	local sbar = string.rep(sbar_chars[i], 2)

	return sbar
end

function GetFileInfo()
	-- if buffer has 'info' variable, return it
	if vim.b.info then
		return vim.b.info
	end
	return ""
end

vim.api.nvim_set_hl(0, "Substitute", { ctermfg = "white", ctermbg = "black" })

vim.opt.statusline = "%<%f%h%m%r%{v:lua.GetFileInfo()}%=%b 0x%B %l,%c%V %{v:lua.GetScrollbar()} %P"

-----------------------------------------------------------
-- Keymaps
-----------------------------------------------------------
vim.keymap.set("n", "J", "<nop>")
vim.keymap.set("v", "K", "<nop>")

-- Clear search highlighting with <leader> and c
vim.keymap.set("n", "<leader>a", ":nohl<CR>")

-- Reload configuration without restart nvim
vim.keymap.set("n", "<leader>R", ":source ~/.config/nvim/init.lua|Msg init.lua reloaded!<CR>")

-- Fast saving with <leader> and s
vim.keymap.set("n", "<leader>w", function()
	vim.cmd("write")
	vim.notify("File saved")
end)
vim.keymap.set("n", "<leader>r", function()
	vim.cmd("edit")
	vim.notify("Reloaded")
end)

-- Replace
vim.keymap.set("n", "<C-s>r", "<ESC>*:%s///gc<left><left><left>")
vim.keymap.set("n", "<C-s>R", "<ESC>*:%s///g<left><left>")

-- Additional normal mode mapping
vim.keymap.set("n", "<leader>e", ":Shell ")

-- Remap incsearch
vim.keymap.set("n", "*", "#N")
vim.keymap.set("n", "#", "*N")
vim.keymap.set("v", "#", 'y/\\V<C-R>"<CR>')
vim.keymap.set("v", "*", 'y?\\V<C-R>"<CR>')

-- Remap tab operations
vim.keymap.set("n", "to", ":tabnew<cr>")
vim.keymap.set("n", "tq", ":tabclose<cr>")
vim.keymap.set("n", "tn", ":tabnext<cr>")
vim.keymap.set("n", "tp", ":tabprev<cr>")

vim.keymap.set("n", "<C-p>", '"0p')
vim.keymap.set("v", "<C-p>", '"0p')

-- Map cursor move on insert mode
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")
vim.keymap.set("i", "<C-l>", "<Right>")

vim.keymap.set("i", "<C-a>", "<ESC>^i")
vim.keymap.set("i", "<C-e>", "<ESC>$a")

-- Copy current file path to clipboard
vim.keymap.set("n", "<leader>y", ":let @*=expand('%:p')<CR>:echo 'Copied to clipboard'<CR>")

vim.keymap.set("n", "qn", ":cnext<CR>")
vim.keymap.set("n", "qp", ":cprev<CR>")
vim.keymap.set("n", "qs", ":copen<CR>")

-----------------------------------------------------------
-- Highlight
-----------------------------------------------------------
vim.api.nvim_set_hl(0, "Comment", { ctermfg = 3 })
vim.api.nvim_set_hl(0, "SignColumn", { ctermbg = nil })
vim.api.nvim_set_hl(0, "Search", { ctermfg = "black", ctermbg = "yellow" })
vim.api.nvim_set_hl(0, "Pmenu", { ctermbg = 238 })
vim.api.nvim_set_hl(0, "FloatBorder", { ctermfg = 3 })
vim.api.nvim_set_hl(0, "MatchParen", { ctermbg = 238, ctermfg = 3, underline = true })

-----------------------------------------------------------
-- Enable LSPs
-----------------------------------------------------------
---[[AUTOCOMPLETION SETUP
vim.o.complete = ".,t"
vim.o.completeopt = "menu,menuone,noselect,noinsert,popup,fuzzy"

---[[ Setup keymaps so we can accept completion using Enter and choose items using Tab.
local pumMaps = {
	["<Tab>"] = "<C-n>",
	["<S-Tab>"] = "<C-p>",
	["<CR>"] = "<C-y>",
}
for insertKmap, pumKmap in pairs(pumMaps) do
	vim.keymap.set("i", insertKmap, function()
		return vim.fn.pumvisible() == 1 and pumKmap or insertKmap
	end, { expr = true })
end
---]]

-- insert mode autocomplete
local group = vim.api.nvim_create_augroup("ins-autocomplete", {})
local complete_in_progress = false

local lsp_triggers = { ".", ":", ">", "(", "," }

vim.api.nvim_create_autocmd("InsertCharPre", {
	desc = "filepath & lsp & keyword completion",
	group = group,
	callback = function(args)
		if
			complete_in_progress
			or vim.fn.pumvisible() ~= 0
			or vim.tbl_contains({ "terminal", "prompt", "help" }, vim.bo[args.buf].buftype)
		then
			return
		end

		complete_in_progress = true -- lock

		if vim.v.char == "/" then
			vim.api.nvim_feedkeys(vim.keycode("<C-X><C-F>"), "ni", false)
		elseif vim.tbl_contains(lsp_triggers, vim.v.char) then
			vim.schedule(function()
				if
					vim.lsp.get_clients({
						bufnr = args.buf,
						method = vim.lsp.protocol.Methods.textDocument_completion,
					})[1]
				then
					vim.lsp.completion.get()
				end
				complete_in_progress = false
			end)
			return
		elseif
			not vim.tbl_isempty(vim.lsp.get_clients({
				bufnr = args.buf,
				method = vim.lsp.protocol.Methods.textDocument_completion,
			}))
		then
			vim.lsp.completion.get()
		elseif vim.fn.match(vim.v.char, [[\k]]) ~= -1 then
			vim.api.nvim_feedkeys(vim.keycode("<C-N>"), "ni", false)
		end
	end,
})

vim.api.nvim_create_autocmd("TextChangedI", {
	desc = "multi-char trigger completion",
	group = group,
	callback = function(args)
		if complete_in_progress or vim.fn.pumvisible() ~= 0 then
			complete_in_progress = false
			return
		end

		local _, col = unpack(vim.api.nvim_win_get_cursor(0))
		if col < 2 then
			return
		end

		local line = vim.api.nvim_get_current_line()
		local two_char = line:sub(col - 1, col)

		local multi_triggers = { "::", "->", "?." }
		if vim.tbl_contains(multi_triggers, two_char) then
			if
				vim.lsp.get_clients({
					bufnr = args.buf,
					method = vim.lsp.protocol.Methods.textDocument_completion,
				})[1]
			then
				vim.lsp.completion.get()
			end
		end

		complete_in_progress = false
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "auto enable lsp completion if capable",
	group = group,
	callback = function(args)
		local client_id = args.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)
		if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
			vim.lsp.completion.enable(true, client_id, args.buf)
		end
	end,
})

-- Enable all
vim.lsp.enable(constant.lsp_servers)

vim.cmd([[
augroup diffcolors
  autocmd!
  autocmd Colorscheme * call s:SetDiffHighlights()
augroup END

function! s:SetDiffHighlights()
  if &background == "dark"
    highlight DiffAdd gui=bold guifg=none guibg=#2e4b2e
    highlight DiffDelete gui=bold guifg=none guibg=#4c1e15
    highlight DiffChange gui=bold guifg=none guibg=#45565c
    highlight DiffText gui=bold guifg=none guibg=#996d74
  else
    highlight DiffAdd gui=bold guifg=none guibg=palegreen
    highlight DiffDelete gui=bold guifg=none guibg=tomato
    highlight DiffChange gui=bold guifg=none guibg=lightblue
    highlight DiffText gui=bold guifg=none guibg=lightpink
  endif
endfunction
]])
