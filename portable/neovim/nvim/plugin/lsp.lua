if require("modules.plugin").mark_as_loaded("lsp") then
	return
end

-----------------------------------------------------------
-- Enable LSPs
-----------------------------------------------------------
---[[AUTOCOMPLETION SETUP
vim.o.complete = ".,t"
vim.o.completeopt = "menu,menuone,noselect,noinsert,popup,fuzzy"

-- vim.diagnostic.config()

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

-- insert mode autocomplete with comment detection
local group = vim.api.nvim_create_augroup("ins-autocomplete", {})
local complete_in_progress = false
local lsp_triggers = { ".", ":", ">", "(", "," }

-- Function to check if cursor is in a comment or string
local function is_in_comment_or_string()
	local col = vim.fn.col(".") - 1

	-- Get syntax name at cursor position
	local stack = vim.fn.synstack(vim.fn.line("."), col)
	if #stack > 0 then
		for i = #stack, 1, -1 do
			local synID = stack[i]
			local name = vim.fn.synIDattr(synID, "name"):lower()
			local group = vim.fn.synIDattr(vim.fn.synIDtrans(synID), "name"):lower()

			-- Check for comment or string
			if name:match("comment") or group:match("comment") or name:match("string") or group:match("string") then
				return true
			end
		end
	end

	return false
end

vim.api.nvim_create_autocmd("InsertCharPre", {
	desc = "filepath & lsp & keyword completion",
	group = group,
	callback = function(args)
		-- Early return for comments/strings
		if is_in_comment_or_string() then
			return
		end

		-- Skip if already completing, popup visible, or special buffer
		if
			complete_in_progress
			or vim.fn.pumvisible() ~= 0
			or vim.tbl_contains({ "terminal", "prompt", "help" }, vim.bo[args.buf].buftype)
		then
			return
		end

		complete_in_progress = true

		-- Handle different triggers
		if vim.v.char == "/" then
			vim.api.nvim_feedkeys(vim.keycode("<C-X><C-F>"), "ni", false)
		elseif vim.tbl_contains(lsp_triggers, vim.v.char) then
			vim.schedule(function()
				complete_in_progress = false
				if not is_in_comment_or_string() then
					local clients = vim.lsp.get_clients({
						bufnr = args.buf,
						method = vim.lsp.protocol.Methods.textDocument_completion,
					})
					if clients[1] then
						vim.lsp.completion.get()
					end
				end
			end)
			return -- Early return to keep complete_in_progress = true
		elseif vim.fn.match(vim.v.char, [[\k]]) ~= -1 then
			-- For keyword characters, only complete if we have LSP or enough context
			local col = vim.fn.col(".") - 1
			local line = vim.fn.getline(".")
			local before_cursor = line:sub(1, col)

			-- Only trigger if we already have at least 2 characters typed
			if #before_cursor >= 1 and before_cursor:match("%w$") then
				if
					not vim.tbl_isempty(vim.lsp.get_clients({
						bufnr = args.buf,
						method = vim.lsp.protocol.Methods.textDocument_completion,
					}))
				then
					vim.lsp.completion.get()
				else
					vim.api.nvim_feedkeys(vim.keycode("<C-N>"), "ni", false)
				end
			else
				complete_in_progress = false
				return
			end
		else
			complete_in_progress = false
			return
		end

		complete_in_progress = false
	end,
})

vim.api.nvim_create_autocmd("TextChangedI", {
	desc = "multi-char trigger completion",
	group = group,
	callback = function(args)
		-- Early return for comments/strings
		if is_in_comment_or_string() then
			return
		end

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
			local clients = vim.lsp.get_clients({
				bufnr = args.buf,
				method = vim.lsp.protocol.Methods.textDocument_completion,
			})
			if clients[1] then
				vim.lsp.completion.get()
			end
		end
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

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		-- Set your LSP keymaps here using vim.keymap.set with buffer option
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
		vim.keymap.set("n", "<space>i", vim.lsp.buf.implementation, { buffer = bufnr })
		vim.keymap.set("n", "<space>k", vim.lsp.buf.signature_help, { buffer = bufnr })
		-- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { buffer = bufnr })
		-- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { buffer = bufnr })
		-- vim.keymap.set("n", "<space>wl", function() -- print workspace folders
		-- print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		-- end, { buffer = bufnr })
		vim.keymap.set("n", "<space>d", vim.lsp.buf.type_definition, { buffer = bufnr })
		vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = bufnr })
		vim.keymap.set("n", "gca", vim.lsp.buf.code_action, { buffer = bufnr })
		vim.keymap.set("n", "go", vim.lsp.buf.references, { buffer = bufnr })
		if client and client.server_capabilities.documentFormattingProvider then
			vim.keymap.set("n", "qf", vim.lsp.buf.format, { buffer = bufnr })
		end
		vim.keymap.set("n", "<space>h", function() -- toggle inlay hints
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, { buffer = bufnr })

		vim.keymap.set("n", "J", vim.diagnostic.open_float, { buffer = bufnr })
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr })
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr })
		vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { buffer = bufnr })
	end,
})

-- Enable all
local constant = require("modules.constant")
vim.lsp.enable(constant.lsp_servers)
