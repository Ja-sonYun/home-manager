vim9script

def EnsurePyreflyConfig(cwd: string): void
  if !isdirectory(cwd .. '/.venv')
    return
  endif

  const cfg = cwd .. '/pyrefly.toml'
  if filereadable(cfg)
    return
  endif

  const pyvenv_cfg = cwd .. '/.venv/pyvenv.cfg'
  if !filereadable(pyvenv_cfg)
    return
  endif

  const lines = readfile(pyvenv_cfg)
  var version = ''
  for line in lines
    if line =~# '^version_info = '
      version = substitute(line, '^version_info = ', '', '')
      break
    endif
  endfor

  const data = [
    "[tool.pyrefly]",
    "python-interpreter = \".venv/bin/python3\"",
    "python-version = \"" .. version .. "\"",
    "include = [\"src\"]",
  ]

  writefile(data, cfg)
enddef

def SetAutocmdsForPyrefly(): void
  augroup PyreflyAuto
    autocmd!
    autocmd BufEnter *.py call EnsurePyreflyConfig(getcwd())
  augroup END
enddef

def g:LspConfig_pyrefly(): dict<any>
  augroup PyreflyAuto
    autocmd!
    autocmd User LspAttached call SetAutocmdsForPyrefly()
  augroup END

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
