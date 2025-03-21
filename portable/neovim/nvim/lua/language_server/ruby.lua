local M = {}

M.ruby_lsp = function()
	if vim.fn.executable("ruby-lsp") then
		local root_files = {
			"Gemfile",
			"Rakefile",
			"config.ru",
			".git",
		}

		vim.lsp.start({
			name = "ruby_lsp",
			cmd = { "ruby-lsp" },
			root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
			capabilities = require("modules.lsp").make_client_capabilities(),
		})
	else
		vim.notify("ruby-lsp not found", vim.log.levels.ERROR)
	end
end

return M
