return {
  cmd = { 'terraform-ls', 'serve' },
  root_markers = {
    'flake.nix',
    'default.nix',
    'shell.nix',
    '.terraform',
    '.terraform.lock.hcl',
    '.git',
    '.gitignore',
    '.gitmodules',
  },
  filetypes = { 'hcl', 'tf', 'tfvars', 'terraform' },
}
