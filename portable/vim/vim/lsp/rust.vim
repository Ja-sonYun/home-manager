vim9script

def g:LspConfig_rust(): dict<any>
  return {
    name: 'rust-analyzer',
    filetype: ['rust'],
    path: exepath('rust-analyzer'),
    rootSearch: ['Cargo.toml', 'Cargo.lock'],
  }
enddef
