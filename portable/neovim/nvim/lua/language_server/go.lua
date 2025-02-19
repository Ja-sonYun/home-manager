local M = {}

M.gopls = function()
  if vim.fn.executable('gopls') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      'go.mod',
      'go.sum',
      '.git',
      '.gitignore',
      '.gitmodules',
    }

    vim.lsp.start {
      name = 'gopls',
      cmd = { 'gopls', 'serve' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('bash-language-server not found', vim.log.levels.ERROR)
  end
end

return M
