local M = {}

--- Prints a table or string
--- @param opts table
--- @return nil
M.set_buffer_opts = function(opts)
  local width = opts.width or 2
  vim.opt_local.shiftwidth = width
  vim.opt_local.tabstop = width
  vim.opt_local.expandtab = true
  vim.opt_local.listchars:append {
    tab = '> ',
    leadmultispace = '.' .. string.rep(' ', width - 1),
  }

  vim.b.is_code = opts.is_code or false
end

--- Execute a command when the directory of the current buffer changes
--- @param filetype table
--- @param func function
M.on_buffer_change = function(filetype, func)
  vim.api.nvim_create_autocmd('BufLeave', {
    group = vim.api.nvim_create_augroup('on_buffer_change_enter', { clear = true }),
    pattern = filetype,
    callback = function()
      M.last_dir = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':h')
    end,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('on_buffer_change_enter', { clear = true }),
    callback = function()
      local current_dir = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':h')
      if M.last_dir and M.last_dir ~= current_dir then
        vim.notify('Directory changed from ' .. M.last_dir .. ' to ' .. current_dir)
        func(M.last_dir, current_dir)
      end
    end,
  })
end

M.uuid = function()
  local random = math.random
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
    return string.format('%x', v)
  end)
end

return M
