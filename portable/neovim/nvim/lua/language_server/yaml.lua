local M = {}

M.yaml_language_server = function()
  if vim.fn.executable('yaml-language-server') then
    local root_files = vim.g.rooter_patterns

    vim.lsp.start {
      name = 'yaml-language-server',
      cmd = { 'yaml-language-server' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('yaml-language-server not found', vim.log.levels.ERROR)
  end
end

return M
