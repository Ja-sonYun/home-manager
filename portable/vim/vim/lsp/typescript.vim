vim9script

def g:LspConfig_typescript(): dict<any>
  return {
    name: 'typescript-language-server',
    filetype: ['typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
    path: exepath('typescript-language-server'),
    args: ['--stdio'],
    rootSearch: [
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
      'package-lock.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'node_modules',
    ],
    workspaceConfig: {
      typescript: {
        inlayHints: {
          includeInlayEnumMemberValueHints: true,
          includeInlayFunctionLikeReturnTypeHints: true,
          includeInlayFunctionParameterTypeHints: true,
          includeInlayParameterNameHints: 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName: true,
          includeInlayPropertyDeclarationTypeHints: true,
          includeInlayVariableTypeHints: true,
        },
      },
    },
  }
enddef
