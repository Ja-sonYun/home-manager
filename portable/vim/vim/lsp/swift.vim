vim9script

def g:LspConfig_swift(): dict<any>
  return {
    name: 'sourcekit-lsp',
    filetype: ['swift'],
    path: exepath('xcrun'),
    args: ['sourcekit-lsp'],
    rootSearch: ['Package.swift', '.xcodeproj', '.xcworkspace'],
  }
enddef
