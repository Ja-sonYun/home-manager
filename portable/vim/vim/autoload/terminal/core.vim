vim9script

g:_shell_buffer_opened = false
g:_shell_current_wid = -1

def ExpandFileMods(s: string): string
  var r = s
  r = substitute(r, '%:S', expand('%:S'), 'g')
  r = substitute(r, '%:p', expand('%:p'), 'g')
  r = substitute(r, '%',   expand('%:S'), 'g')
  return r
enddef

def CloseBuffer(buf: number, prev_status: number): void
  g:_shell_current_wid = -1
  g:_shell_buffer_opened = false

  &laststatus = prev_status

  if bufexists(buf)
    execute 'bdelete!' buf
  endif
enddef

def RestoreLaststatus(prev: number): void
enddef

def ShellPrompt(cmd: string): string
  return 'trap : INT;' .. cmd
    .. "\n"
    .. "printf '\\n[exit_code:%s] %s' $? 'Press enter to continue...' && read ans"
enddef

def StripAnsi(text: string): string
  var result = substitute(text, '\%x1b].\{-}\x07', '', 'g')
  result = substitute(result, '\%(\%x1b\)\?\[[0-9;?]*[ -/]*[@-~]', '', 'g')
  result = substitute(result, '\r', '', 'g')
  return result
enddef

def AttachTermMappings(): void
  tnoremap <buffer> <Esc> <C-\><C-n>
  nnoremap <silent><buffer> q          <Cmd>bdelete!<CR>
  nnoremap <silent><buffer> <C-c>      <Cmd>bdelete!<CR>
  nnoremap <silent><buffer> <leader>qf <Cmd>cexpr getline(1, line('$') - 2)<CR>:q<CR>:copen<CR>
enddef

def AttachQuitHandlers(): void
  tnoremap <silent><buffer> <C-q> <C-\><C-n><Cmd>bdelete!<CR>
  cnoreabbrev <buffer> <expr> q     (getcmdtype() == ':' && getcmdline() =~# '^\s*q!?$')     ? 'bdelete!' : 'q'
  cnoreabbrev <buffer> <expr> quit  (getcmdtype() == ':' && getcmdline() =~# '^\s*quit!?$')  ? 'bdelete!' : 'quit'
  cnoreabbrev <buffer> <expr> close (getcmdtype() == ':' && getcmdline() =~# '^\s*close!?$') ? 'bdelete!' : 'close'
  augroup TerminalQuitGuard
    autocmd!
    autocmd QuitPre <buffer> if v:dying == 0 | bdelete! | endif
  augroup END
enddef

def StartTerminal(cmd: string, height: number, qf: bool = false): bool
  if g:_shell_buffer_opened
    echohl ErrorMsg
    echomsg 'Shell already opened!'
    echohl None
    return false
  endif

  botright new
  execute 'resize ' .. height
  const buf = bufnr()

  setlocal nonumber norelativenumber nocursorline signcolumn=no
  setlocal bufhidden=wipe
  setlocal nobuflisted

  const prev_ls = &laststatus
  b:prev_laststatus = prev_ls

  const prev_hidden = &hidden
  b:prev_hidden = prev_hidden
  set hidden

  var wrapped_cmd = cmd
  var teetemp = ''
  if qf
    teetemp = tempname()
    wrapped_cmd = printf(
          \ "echo '$ %s\n---------'; %s | tee %s && sed -i -r 's/\\x1B\\[[0-9;]*[mK]//g' %s",
          \ shellescape(cmd, 1),
          \ cmd,
          \ fnameescape(teetemp),
          \ fnameescape(teetemp))
  endif
  const safe_cmd = ShellPrompt(wrapped_cmd)

  try
    term_start(['sh', '-c', safe_cmd], {
      curwin: true,
      exit_cb: (job: job, status: number) => {
        CloseBuffer(buf, prev_ls)
        if qf
          def LoadQuickfix(_: number): void
            execute 'cgetfile ' .. fnameescape(teetemp)
            call delete(teetemp)
            execute 'copen'
          enddef

          call timer_start(0, LoadQuickfix)
        endif
      },
    })
  catch
    echohl ErrorMsg
    echomsg 'Failed to start terminal job: ' .. v:exception .. ' at ' .. v:throwpoint
    echohl None
    CloseBuffer(buf, prev_ls)
    return false
  endtry

  AttachTermMappings()
  AttachQuitHandlers()
  &laststatus = 0
  &l:winfixheight = true
  &l:winfixwidth = true
  startinsert
  g:_shell_current_wid = win_getid()
  g:_shell_buffer_opened = true
  return true
enddef

export def Run(cmd: string, height: number = 10, qf: bool = false): void
  const resolved = ExpandFileMods(cmd)
  StartTerminal(resolved, max([3, height]), qf)
enddef

export def Make(args: string = '', height: number = 10): void
  execute 'cclose'
  var cmd = &makeprg
  if empty(cmd)
    cmd = 'make'
  endif
  if !empty(args)
    cmd = cmd .. ' ' .. args
  endif
  Run(cmd, height, true)
enddef

def RunWindowRunning(): void
  if g:_shell_current_wid != win_getid()
    return
  endif
  try
    win_execute(g:_shell_current_wid, 'noautocmd normal! i')
  catch
  endtry
enddef

export def Setup(): void
  command! -nargs=* -complete=shellcmd Sh {
    Run(<q-args>)
  }
  command! -nargs=* -complete=shellcmd Make {
    Make(<q-args>)
  }

  augroup TerminalShellWindowFocus
    autocmd!
    autocmd WinLeave * call RunWindowRunning()
    autocmd WinEnter * call RunWindowRunning()
  augroup END
enddef

defcompile
