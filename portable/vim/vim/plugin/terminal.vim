vim9script

g:shell_opened = 0

def OnTermExit(buf: number, prev_ls: number, _j: any, _status: number)
  g:shell_opened = 0
  &laststatus = prev_ls
  if bufexists(buf)
    execute 'bdelete!' buf
  endif
enddef

export def OnBufWipeout(abuf: any)
  g:shell_opened = 0
  var b = str2nr(string(abuf))
  var prev = getbufvar(b, 'prev_laststatus', &laststatus)
  &laststatus = prev
enddef

def TerminalShell(cmd: string, height: number)
  botright new
  execute 'resize ' .. height
  const b = bufnr()

  setlocal nonumber norelativenumber nocursorline signcolumn=no

  const prev_ls = &laststatus
  b:prev_laststatus = prev_ls

  const safe = 'trap : INT;' .. cmd .. "; printf '\\n[exit_code:%s] %s' $? 'Press enter to continue...' && read ans"

  const Cb = function('OnTermExit', [b, prev_ls])
  try
    call term_start(['sh', '-c', safe], { curwin: true, exit_cb: Cb })
  catch
    g:shell_opened = 0
    echomsg 'Failed to start terminal job'
    execute 'bdelete!' b
    return
  endtry

  tnoremap <buffer> <Esc> <C-\><C-n>
  nnoremap <buffer> q :bdelete!<CR>
  nnoremap <buffer> <C-c> :bdelete!<CR>

  augroup ShellTermBuf
    autocmd!
    autocmd BufWipeout <buffer> OnBufWipeout(expand('<abuf>'))
  augroup END

  &laststatus = 0
  startinsert
enddef

export def RunCmd(args: string)
  const cmd = substitute(args, '%', expand('%:p'), 'g')
  if g:shell_opened == 1
    echomsg 'Shell already opened!'
    return
  endif
  g:shell_opened = 1
  TerminalShell(cmd, 15)
enddef

command! -nargs=* -complete=shellcmd Sh RunCmd(<q-args>)
nnoremap <leader>e :Sh 
