vim9script

def g:LspConfig_ruby(): dict<any>
  return {
    name: 'ruby-lsp',
    filetype: ['ruby'],
    path: exepath('ruby-lsp'),
    rootSearch: ['Gemfile', 'Gemfile.lock', '.ruby-version', '.ruby-gemset'],
  }
enddef
