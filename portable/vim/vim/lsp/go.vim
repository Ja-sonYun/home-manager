vim9script

def g:LspConfig_go(): dict<any>
  return {
    name: 'gopls',
    filetype: ['go'],
    path: exepath('gopls'),
    args: ['serve'],
    rootSearch: ['go.mod', 'go.work'],
  }
enddef
