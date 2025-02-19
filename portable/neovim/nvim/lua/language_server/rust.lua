local M = {}

M.rust_analyzer = function()
  if vim.fn.executable('rust-analyzer') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      'Cargo.toml',
      'Cargo.lock',
      'rust-toolchain',
      'src',
      '.git',
      '.gitignore',
      '.gitmodules',
    }

    vim.lsp.start {
      name = 'rust-analyzer',
      cmd = { 'rust-analyzer' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('rust-analyzer not found', vim.log.levels.ERROR)
  end
end

return M
