local M = {}

M.bash_language_server = function()
  if vim.fn.executable('bash-language-server') then
    local root_files = vim.g.rooter_patterns

    vim.lsp.start {
      name = 'bash-language-server',
      cmd = { 'bash-language-server', 'start' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('bash-language-server not found', vim.log.levels.ERROR)
  end
end

return M
