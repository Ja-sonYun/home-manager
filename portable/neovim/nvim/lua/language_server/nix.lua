local M = {}

M.nil_ls = function()
  if vim.fn.executable('nil') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      '.git',
    }

    vim.lsp.start {
      name = 'nil_ls',
      cmd = { 'nil' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('nil_ls not found', vim.log.levels.ERROR)
  end
end

return M
