local M = {}

M.tsserver = function()
  if vim.fn.executable('tsserver') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      'package.json',
      'tsconfig.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'package-lock.json',
      '.git',
      '.gitignore',
      '.gitmodules',
    }

    vim.lsp.start {
      name = 'tsserver',
      cmd = { 'typescript-language-server', '--stdio' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
      settings = {
        typescript = {
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = true,
          },
        },
      },
    }
  else
    vim.notify('tsserver not found', vim.log.levels.ERROR)
  end
end

return M
