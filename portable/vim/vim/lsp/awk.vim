vim9script

def g:LspConfig_awk(): dict<any>
  return {
    name: 'awkls',
    filetype: ['awk'],
    path: exepath('awk-language-server'),
    args: [],
  }
enddef
