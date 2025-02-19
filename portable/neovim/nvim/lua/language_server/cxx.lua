local M = {}

M.ccls = function()
  if vim.fn.executable('ccls') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      'Makefile',
      '.git',
      'compile_flags.txt',
      'compile_commands.json',
      'CMakeLists.txt',
      'build.ninja',
      'build.ninja.in',
      'meson.build',
      'meson_options.txt',
      'src',
    }

    vim.lsp.start {
      name = 'ccls',
      cmd = { 'ccls' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('ccls not found', vim.log.levels.ERROR)
  end
end

return M
