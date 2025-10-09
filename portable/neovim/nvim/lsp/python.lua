local function wrap_completion_request(client)
	local function unquote_pair(s)
		if type(s) ~= "string" then
			return nil
		end
		local _, inner = s:match("^(['\"])(.*)%1$")
		return inner
	end

	local function fix_item(item)
		if type(item) ~= "table" then
			return
		end

		local te = item.textEdit
		local nt = (te and te.newText) or item.insertText or item.label
		local inner = unquote_pair(nt)

		if inner then
			if te and type(te.newText) == "string" then
				te.newText = inner
				local r = te.range
				if r and r.start and r["end"] then
					r.start.character = r.start.character + 1
					r["end"].character = r["end"].character - 1
				end
			elseif type(item.insertText) == "string" then
				item.insertText = inner
			end
		end

		local lbl_inner = unquote_pair(item.label)
		if lbl_inner then
			item.label = lbl_inner
		end
	end

	local orig_request = client.request
	client.request = function(self, method, params, handler, bufnr, config)
		if method ~= "textDocument/completion" then
			return orig_request(self, method, params, handler, bufnr, config)
		end

		local wrapped = function(err, result, ctx)
			if type(result) == "table" then
				local items = result.items or result
				for i = 1, #items do
					fix_item(items[i])
				end
			end
			return handler(err, result, ctx)
		end

		return orig_request(self, method, params, wrapped, bufnr, config)
	end
end

return {
	cmd = { "pyright-langserver", "--stdio" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"Pipfile",
		"Pipfile.lock",
		"requirements.txt",
		".venv",
	},
	filetypes = { "python" },
	settings = {
		python = {},
	},
	before_init = function(_, config)
		require("rooter").wait_until_ready()
		local python_executable, _ = require("modules.pylib").get_python_path()
		config.settings.python.pythonPath = python_executable
	end,
	on_attach = function(client, _)
		wrap_completion_request(client)
	end,
}
