vim9script

def g:LspConfig_nil(): dict<any>
  return {
    name: 'nil',
    filetype: ['nix'],
    path: exepath('nil'),
    rootSearch: ['flake.nix', 'flake.lock', 'shell.nix'],
  }
enddef
