vim9script

def g:LspConfig_lua(): dict<any>
  var libPaths: list<string> = []
  if exists('$LUA_LS_LIB') && !empty($LUA_LS_LIB)
    var sep = has('win32') ? ';' : ':'
    for entry in split($LUA_LS_LIB, sep)
      if !empty(entry)
        add(libPaths, entry)
      endif
    endfor
  endif

  var library: list<string> = []
  if exists('$VIMRUNTIME')
    add(library, expand('$VIMRUNTIME'))
  endif
  if !libPaths->empty()
    extend(library, libPaths)
  endif

  return {
    name: 'lua-language-server',
    filetype: ['lua'],
    path: exepath('lua-language-server'),
    rootSearch: ['lua-language-server.json', '.git', '.luarc.json'],
    workspaceConfig: {
      Lua: {
        runtime: {
          version: 'LuaJIT',
        },
        diagnostics: {
          globals: ['vim', 'describe', 'it', 'assert', 'stub'],
          disable: ['duplicate-set-field'],
        },
        workspace: {
          checkThirdParty: false,
          library: library,
        },
        telemetry: {
          enable: false,
        },
        hint: {
          enable: true,
        },
      },
    },
  }
enddef
