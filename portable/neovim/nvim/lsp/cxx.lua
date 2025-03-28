return {
  cmd = { 'ccls' },
  root_markers = {
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
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
}
