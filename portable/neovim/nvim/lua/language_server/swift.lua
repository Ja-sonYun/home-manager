local M = {}

M.sourcekit_lsp = function()
  if vim.fn.executable('sourcekit-lsp') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      'Package.swift',
      'Sources',
      'Tests',
      'Makefile',
      '.git',
      '.gitignore',
      '.gitmodules',
    }

    vim.lsp.start {
      name = 'sourcekit-lsp',
      cmd = { 'sourcekit-lsp' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('sourcekit-lsp not found', vim.log.levels.ERROR)
  end
end

return M
