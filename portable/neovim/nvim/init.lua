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

vim.opt.timeoutlen = 400 -- Time to wait for a mapped sequence to complete

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
vim.opt.signcolumn = "auto:2"

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
-- vim.opt.shortmess:append("sI")

-----------------------------------------------------------
-- DefaultTheme
-----------------------------------------------------------
vim.opt.background = "light" -- Dark background

vim.cmd([[colorscheme vim]])

-----------------------------------------------------------
-- Keymaps
-----------------------------------------------------------
vim.keymap.set("n", "J", "<nop>")
vim.keymap.set("v", "K", "<nop>")

-- Clear search highlighting with <leader> and c
vim.keymap.set("n", "<leader>a", ":nohl<CR>")

-- Reload configuration without restart nvim
vim.keymap.set("n", "<leader>R", ":source ~/.config/nvim/init.lua|lua vim.notify('init.lua reloaded!')<CR>")

-- Fast saving with <leader> and s
vim.keymap.set("n", "<leader>w", function()
	vim.cmd("write")
	vim.notify("File saved")
end)
vim.keymap.set("n", "<leader>r", function()
	vim.cmd("edit")
	vim.notify("Reloaded")
end)

-- Switch between buffers
vim.keymap.set("n", "<leader><leader>", "<C-^>")

-- vim.keymap.set("v", "K", "")

-- Smart line movement
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Visual line movement
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- Replace current text
vim.keymap.set("n", "<C-s>r", [[:%s/\<<C-r><C-w>\>//gc<left><left><left>]])
vim.keymap.set("n", "<C-s>R", [[:%s/\<<C-r><C-w>\>//g<left><left>]])

-- Replace in visual selection only
vim.keymap.set("v", "<C-s>r", [[:s/\%V/gc<left><left><left>]])
vim.keymap.set("v", "<C-s>R", [[:s/\%V/g<left><left>]])

-- Additional normal mode mapping
vim.keymap.set("n", "<leader>e", ":Shell ")

-- Remap incsearch
vim.keymap.set("n", "*", "#N")
vim.keymap.set("n", "#", "*N")
vim.keymap.set("v", "#", [[y:let @/='\V'.substitute(escape(@", '\'), '/', '\\/', 'g')<CR>n]])
vim.keymap.set("v", "*", [[y:let @/='\V'.substitute(escape(@", '\'), '/', '\\/', 'g')<CR>N]])

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

vim.keymap.set("n", "qo", ":copen<CR>")
vim.keymap.set("n", "qd", ":Dispatch ")

vim.keymap.set("n", "qu", ":UndotreeToggle<CR>")

-----------------------------------------------------------
-- Highlight
-----------------------------------------------------------
vim.api.nvim_set_hl(0, "Comment", { ctermfg = 3 })
vim.api.nvim_set_hl(0, "SignColumn", { ctermbg = nil })
vim.api.nvim_set_hl(0, "Search", { ctermfg = "black", ctermbg = "yellow" })
vim.api.nvim_set_hl(0, "Pmenu", { ctermbg = 238 })
vim.api.nvim_set_hl(0, "FloatBorder", { ctermfg = 3 })
vim.api.nvim_set_hl(0, "MatchParen", { ctermbg = 238, ctermfg = 3, underline = true })

vim.api.nvim_set_hl(0, "DiffAdd", { ctermbg = 17, bold = true })
vim.api.nvim_set_hl(0, "DiffChange", { ctermbg = 235, bold = true })
vim.api.nvim_set_hl(0, "DiffText", { ctermbg = 238, bold = true, underline = true })
vim.api.nvim_set_hl(0, "DiffDelete", { ctermbg = 52, ctermfg = 255, bold = true })

vim.api.nvim_set_hl(0, "Folded", { ctermbg = 248, ctermfg = 0, bold = true })
vim.api.nvim_set_hl(0, "FoldColumn", { ctermbg = 248, ctermfg = 0, bold = true })

vim.api.nvim_set_hl(0, "Substitute", { ctermbg = 3, ctermfg = 0, bold = true })

vim.api.nvim_set_hl(0, "NormalFloat", { ctermbg = 236, bold = true })
vim.api.nvim_set_hl(0, "Directory", { ctermfg = 6 })

vim.api.nvim_create_user_command("BufOnly", function()
	vim.cmd("%bd|e#|bd#")
end, {})

vim.cmd([[
packadd cfilter
]])
