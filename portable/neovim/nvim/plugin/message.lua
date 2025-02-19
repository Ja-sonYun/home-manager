if require('modules.plugin').mark_as_loaded('message') then
  return
end

vim.api.nvim_create_user_command('Err', function(opts)
  require('modules.message').Msg(opts.args, 'ErrorMsg', { timestamp = true })
end, { nargs = '*' })

vim.api.nvim_create_user_command('Msg', function(opts)
  require('modules.message').Msg(opts.args, 'Search', { timestamp = true })
end, { nargs = '*' })

vim.api.nvim_create_user_command('Ok', function(opts)
  require('modules.message').Msg(opts.args, 'MoreMsg', { timestamp = true })
end, { nargs = '*' })

vim.api.nvim_create_user_command('MsgClear', function()
  require('modules.message').ClearMsg()
end, {})

vim.notify = function(msg, level, opts)
  local hl = nil
  if level == vim.log.levels.ERROR then
    hl = 'ErrorMsg'
  elseif level == vim.log.levels.WARN then
    hl = 'WarningMsg'
  elseif level == vim.log.levels.INFO then
    hl = 'MoreMsg'
  elseif level == vim.log.levels.DEBUG then
    hl = 'Debug'
  else
    hl = 'Search'
  end
  require('modules.message').Msg(msg, hl, { timestamp = true })
end
