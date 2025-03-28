return {
  cmd = { 'gopls', 'serve' },
  root_markers = {
    'flake.nix',
    'default.nix',
    'shell.nix',
    'go.mod',
    'go.sum',
    '.git',
    '.gitignore',
    '.gitmodules',
  },
  filetypes = { 'go' },
}
