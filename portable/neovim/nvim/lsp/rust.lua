return {
  cmd = { 'rust-analyzer' },
  root_markers = {
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
  },
  filetypes = { 'rust' },
}
