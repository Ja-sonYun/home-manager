vim9script

def g:LspConfig_pyrefly(): dict<any>
  return {
    name: 'pyrefly',
    filetype: ['python'],
    path: exepath('pyrefly'),
    args: ['lsp'],
    rootSearch: [
      'pyrefly.toml',
      'pyproject.toml',
      'pyproject.yaml',
      'setup.py',
      'setup.cfg',
      'pyrightconfig.json',
      'Pipfile',
      'Pipfile.lock',
      'requirements.txt',
      '.venv/',
      '.git',
    ],
  }
enddef
