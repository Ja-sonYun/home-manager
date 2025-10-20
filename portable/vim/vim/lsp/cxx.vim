vim9script

def g:LspConfig_cxx(): dict<any>
  return {
    name: 'clangd',
    filetype: ['c', 'cpp', 'objc', 'objcpp'],
    path: exepath('clangd'),
    args: [
      '--background-index',
      '--clang-tidy',
      '--header-insertion=iwyu',
      '--completion-style=detailed',
      '--all-scopes-completion',
    ],
    rootSearch: [
      'compile_commands.json',
      'compile_flags.txt',
      'Makefile',
      'CMakeLists.txt',
      'meson.build',
    ],
  }
enddef
