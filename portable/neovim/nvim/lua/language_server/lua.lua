local M = {}

M.lua_language_server = function()
  local lua_ls_cmd = 'lua-language-server'
  if vim.fn.executable(lua_ls_cmd) then
    local root_files = {
      '.luarc.json',
      '.luarc.jsonc',
      '.luacheckrc',
      '.stylua.toml',
      'stylua.toml',
      'selene.toml',
      'selene.yml',
      '.git',
    }

    vim.lsp.start {
      name = 'luals',
      cmd = { lua_ls_cmd },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global, etc.
            globals = {
              'vim',
              'describe',
              'it',
              'assert',
              'stub',
            },
            disable = {
              'duplicate-set-field',
            },
          },
          workspace = {
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
          hint = { -- inlay hints (supported in Neovim >= 0.10)
            enable = true,
          },
        },
      },
    }
  else
    vim.notify('lua-language-server not found', vim.log.levels.ERROR)
  end
end

return M
