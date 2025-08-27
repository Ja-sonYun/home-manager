if require('modules.plugin').mark_as_loaded('language-server') then
  return
end

vim.api.nvim_create_user_command('LspList', function()
  local clients = vim.lsp.get_clients()

  for _, client in ipairs(clients) do
    local root_dir = (client.config or {}).root_dir or 'N/A'
    print('LSP Client: ' .. client.name .. '[' .. client.id .. ']' .. ', Root Dir: ' .. root_dir)
  end
end, {})

vim.api.nvim_create_user_command('LspLog', function()
  local log = vim.lsp.get_log_path()
  vim.cmd('edit ' .. log)
end, {})

vim.api.nvim_create_user_command('LspRestart', function()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = current_bufnr }
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  -- Wait for the client to stop
  vim.wait(1000)
  vim.cmd('edit')
end, {})

vim.api.nvim_create_user_command('LspStop', function(opts)
  if opts.args ~= '' then
    local client_id = tonumber(opts.args)
    if client_id then
      vim.lsp.stop_client(client_id)
      return
    end
  end
  local current_bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = current_bufnr }
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
end, { nargs = '?' })
