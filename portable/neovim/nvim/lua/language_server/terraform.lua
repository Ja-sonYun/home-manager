local M = {}

M.terraform_ls = function()
  if vim.fn.executable('terraform-ls') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      '.terraform',
      '.terraform.lock.hcl',
      '.git',
      '.gitignore',
      '.gitmodules',
    }

    vim.lsp.start {
      name = 'terraform-ls',
      cmd = { 'terraform-ls', 'serve' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('terraform-ls not found', vim.log.levels.ERROR)
  end
end

return M
