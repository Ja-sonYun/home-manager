if require('modules.plugin').mark_as_loaded('autocmds') then
  return
end

-----------------------------------------------------------
-- Highlight on yank
-----------------------------------------------------------
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = 'IncSearch', timeout = '1000' }
  end,
})

-----------------------------------------------------------
-- Don't auto commenting new lines
-----------------------------------------------------------
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '',
  command = 'set fo-=c fo-=r fo-=o',
})

-----------------------------------------------------------
-- Remove whitespace on save
-----------------------------------------------------------
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '',
  callback = function()
    if not vim.b.is_code then
      return
    end
    vim.cmd(':%s/\\s\\+$//e')
  end,
})

-----------------------------------------------------------
-- Switch Rel - Abs number
-----------------------------------------------------------
local modifyRelativeNumber = vim.api.nvim_create_augroup('ModifyRelativeNumber', { clear = true })
for _, event in ipairs { 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave', 'CmdlineEnter' } do
  vim.api.nvim_create_autocmd(event, {
    group = modifyRelativeNumber,
    callback = function()
      if not vim.b.is_code then
        return
      end

      vim.opt_local.relativenumber = false
    end,
  })
end

for _, event in ipairs { 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter', 'CmdlineLeave' } do
  vim.api.nvim_create_autocmd(event, {
    group = modifyRelativeNumber,
    callback = function()
      if not vim.b.is_code then
        return
      end

      vim.opt_local.number = true
      vim.opt_local.relativenumber = true
    end,
  })
end

-----------------------------------------------------------
-- LspAttach
-----------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Set your LSP keymaps here using vim.keymap.set with buffer option
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
    vim.keymap.set('n', '<space>k', vim.lsp.buf.signature_help, { buffer = bufnr })
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr })
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, { buffer = bufnr })
    vim.keymap.set('n', '<space>wl', function() -- print workspace folders
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { buffer = bufnr })
    vim.keymap.set('n', '<space>d', vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set('n', 'grn', vim.lsp.buf.rename, { buffer = bufnr })
    vim.keymap.set('n', 'gca', vim.lsp.buf.code_action, { buffer = bufnr })
    vim.keymap.set('n', 'go', vim.lsp.buf.references, { buffer = bufnr })
    if client and client.server_capabilities.documentFormattingProvider then
      vim.keymap.set('n', 'qf', vim.lsp.buf.format, { buffer = bufnr })
    end
    vim.keymap.set('n', 'qh', function() -- toggle inlay hints
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { buffer = bufnr })

    vim.keymap.set('n', 'J', vim.diagnostic.open_float, { buffer = bufnr })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr })
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { buffer = bufnr })
  end,
})

-----------------------------------------------------------
-- Dynamic on save callback
-----------------------------------------------------------
-- function is_file_in_glob(pattern, filename)
--   local patterns = vim.split(pattern, ',')
--   for _, pat in ipairs(patterns) do
--     local files = vim.fn.glob(pat, false, true)
--     for _, file in ipairs(files) do
--       if file == filename then
--         return true
--       end
--     end
--   end
--   return false
-- end

-- augroup('OnSaveHook', { clear = true })
-- aucmd('BufWritePost', {
--   group = 'OnSaveHook',
--   pattern = '',
--   callback = function()
--     vim.cmd('Ok File saved!')

--     -- if VIM_ON_SAVE_HOOK_TRIGGER_RULES, assume that is like *.py
--     if vim.env.VIM_ON_SAVE_HOOK then
--       if vim.env.VIM_ON_SAVE_HOOK_TRIGGER_RULES == nil then
--         vim.cmd('!' .. vim.env.VIM_ON_SAVE_HOOK)
--       else
--         local file_hit = is_file_in_glob(vim.env.VIM_ON_SAVE_HOOK_TRIGGER_RULES, vim.fn.expand('%:t'))
--         if file_hit then
--           vim.cmd('!' .. vim.env.VIM_ON_SAVE_HOOK)
--         else
--           vim.cmd('Ok File not matched with VIM_ON_SAVE_HOOK_TRIGGER_RULES')
--         end
--       end
--     end
--   end,
-- })
