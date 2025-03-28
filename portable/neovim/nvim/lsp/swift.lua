return {
  cmd = { 'sourcekit-lsp' },
  root_markers = {
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
  },
  filetypes = { 'swift' },
}
