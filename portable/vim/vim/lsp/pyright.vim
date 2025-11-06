vim9script

g:_lsp_pyright_last_loaded_path = ''

def RestartPyrightServer(): void
  echohl WarningMsg
  echo 'Restarting Pyright server to load .venv configuration...'
  echohl None

  execute 'silent LspServer restart'

  echohl MoreMsg
  echo 'Pyright server restarted.'
  echohl None
enddef

def EnsurePyrightConfig(cwd: string): void
  if g:_lsp_pyright_last_loaded_path == cwd
    return
  endif

  if !isdirectory(cwd .. '/.venv')
    return
  endif

  var cfg = cwd .. '/pyrightconfig.json'
  if filereadable(cfg)
    g:_lsp_pyright_last_loaded_path = cwd
    timer_start(10, (_) => RestartPyrightServer())
    return
  endif
  var data = {
    venvPath: cwd,
    venv: '.venv',
    python: {
      defaultInterpreterPath: '.venv/bin/python'
    },
  }
  writefile([json_encode(data)], cfg)
  g:_lsp_pyright_last_loaded_path = cwd
  timer_start(10, (_) => RestartPyrightServer())
enddef

def SetAutocmdsForPyright(): void
  augroup PyrightAuto
    autocmd!
    autocmd BufEnter *.py call EnsurePyrightConfig(getcwd())
  augroup END
enddef

def g:LspConfig_pyright(): dict<any>
  augroup PyrightAuto
    autocmd!
    autocmd User LspAttached call SetAutocmdsForPyright()
  augroup END

  return {
    name: 'pyright',
    filetype: ['python'],
    path: exepath('pyright-langserver'),
    args: ['--stdio'],
    workspaceConfig: {
      python: {
        pythonPath: 'python3',
      },
    },
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
