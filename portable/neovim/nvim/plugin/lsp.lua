vim.o.complete = ".,t"
vim.o.completeopt = "menu,menuone,noselect,noinsert,popup,fuzzy"

require("autocomp").setup({
	debounce_ms = 20,
	path_trigger = "/",
	lsp_triggers = { ".", ":", ">", "(", ",", "[" },
	multi_triggers = { "::", "->", "?." },
	enable_builtin_pum_maps = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		local b = args.buf
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = b })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = b })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = b })
		vim.keymap.set("n", "<space>i", vim.lsp.buf.implementation, { buffer = b })
		vim.keymap.set("n", "<space>k", vim.lsp.buf.signature_help, { buffer = b })
		vim.keymap.set("n", "<space>d", vim.lsp.buf.type_definition, { buffer = b })
		vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = b })
		vim.keymap.set("n", "gca", vim.lsp.buf.code_action, { buffer = b })
		vim.keymap.set("n", "go", vim.lsp.buf.references, { buffer = b })
		vim.keymap.set("n", "J", vim.diagnostic.open_float, { buffer = b })
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, { buffer = b })
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, { buffer = b })
		vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { buffer = b })
	end,
})

local constant = require("modules.constant")
vim.lsp.enable(constant.lsp_servers)
