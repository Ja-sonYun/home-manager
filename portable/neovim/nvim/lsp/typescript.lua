return {
  cmd = { 'typescript-language-server', '--stdio' },
  root_markers = {
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
  },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
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
