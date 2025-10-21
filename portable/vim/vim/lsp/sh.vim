vim9script

def g:LspConfig_sh(): dict<any>
  return {
    name: 'bash-language-server',
    filetype: ['sh', 'bash', 'zsh'],
    path: exepath('bash-language-server'),
    args: ['start'],
    # Do not start the server for dotenv files
    runUnlessSearch: ['.env', '.env.*', '*.env', '.env.*.*'],
  }
enddef
