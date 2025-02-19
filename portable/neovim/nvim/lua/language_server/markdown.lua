local M = {}

M.marksman = function()
  if vim.fn.executable('marksman') then
    local root_files = vim.g.rooter_patterns

    vim.lsp.start {
      name = 'marksman',
      cmd = { 'marksman', 'server' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
    }
  else
    vim.notify('marksman not found', vim.log.levels.ERROR)
  end
end

return M
