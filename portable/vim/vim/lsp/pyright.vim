vim9script

def g:LspConfig_pyright(): dict<any>
  return {
    name: 'pyright',
    filetype: ['python'],
    path: exepath('pyright-langserver'),
    args: ['--stdio'],
    workspaceConfig: {
      python: {
        pythonPath: '/usr/bin/python3'
      }
    }
  }
enddef
