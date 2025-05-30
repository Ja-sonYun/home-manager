if require('modules.plugin').mark_as_loaded('term') then
  return
end

vim.g.shell_opened = 0

--- Run a shell command in a bottom split and close on <CR>.
---@param cmd string
---@param height number
local function terminal_shell(cmd, height)
  vim.cmd('botright ' .. height .. 'new')
  local safecommand = 'trap : INT;'
    .. cmd
    .. [[;  printf '\n[exit_code:%s] %s' $! 'Press enter to continue...' && read ans]]
  local buf = vim.api.nvim_get_current_buf()

  pcall(vim.treesitter.stop, buf)

  vim.fn.jobstart(safecommand, {
    term = true,
    height = height,
    on_exit = function(_, exit_code)
      vim.notify('Shell exited with code: ' .. exit_code, vim.log.levels.INFO)
      vim.g.shell_opened = 0
      vim.o.laststatus = 2
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })

  vim.keymap.set('n', '<CR>', 'i<CR>', { buffer = buf, silent = true })
  vim.o.laststatus = 0
  vim.cmd('startinsert') -- jump into terminal
end

-- :Shell {args}
vim.api.nvim_create_user_command('Shell', function(opts)
  local cmd = opts.args:gsub('%%', vim.fn.expand('%:p'))
  if vim.g.shell_opened == 1 then
    vim.notify('Shell already opened!', vim.log.levels.ERROR)
    return
  end
  vim.g.shell_opened = 1
  terminal_shell(cmd, 15)
end, { nargs = '*', complete = 'shellcmd' })
