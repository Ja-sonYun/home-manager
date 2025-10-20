vim9script

def g:LspConfig_vim(): dict<any>
  return {
    name: 'vimls',
    filetype: ['vim'],
    path: exepath('vim-language-server'),
    args: ['--stdio'],
  }
enddef
