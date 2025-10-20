vim9script

const script_dir = expand('<sfile>:p:h')
const workspace_dict_path = script_dir .. '/harper.dict'
const user_dict_path = expand('~/.local/share/harper/harper.dict')

def g:LspConfig_harper(): dict<any>
  return {
    name: 'harper-ls',
    filetype: [
      'gitcommit', 'python', 'markdown', 'text', 'latex', 'tex', 'html', 'xml',
      'json', 'yaml', 'toml', 'javascript', 'javascriptreact', 'typescript',
      'typescriptreact', 'vue', 'css', 'scss', 'less', 'php', 'ruby', 'go',
      'rust', 'hcl', 'terraform', 'shell', 'bash', 'fish', 'powershell', 'sql',
      'lua', 'elixir', 'erlang', 'swift', 'kotlin', 'java', 'c', 'cpp',
      'csharp', 'objective-c', 'dart', 'vim'
    ],
    path: exepath('harper-ls'),
    args: ['--stdio'],
    workspaceConfig: {
      'harper-ls': {
        userDictPath: user_dict_path,
        workspaceDictPath: workspace_dict_path,
        fileDictPath: '',
        linters: {
          SpellCheck: true,
          SpelledNumbers: false,
          AnA: true,
          SentenceCapitalization: true,
          UnclosedQuotes: true,
          WrongQuotes: true,
          LongSentences: false,
          RepeatedWords: true,
          Spaces: true,
          Matcher: false,
          CorrectNumberSuffix: true,
        },
        codeActions: {
          ForceStable: false,
        },
        markdown: {
          IgnoreLinkTitle: false,
        },
        isolateEnglish: false,
        dialect: 'American',
      },
    },
  }
enddef
