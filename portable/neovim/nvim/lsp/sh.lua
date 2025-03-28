return {
  cmd = { 'bash-language-server', 'start' },
  root_markers = {
    '.git',
    '.bashrc',
    '.bash_profile',
    '.bash_aliases',
    '.bash_history',
    '.bash_logout',
    '.bash_login',
  },
  filetypes = { 'sh', 'bash', 'zsh' },
}
