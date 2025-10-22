function! s:HasAnyFold()
  for lnum in range(1, line('$'))
    if foldlevel(lnum) > 0
      return v:true
    endif
  endfor
  return v:false
endfunction

function! s:AutoFoldColumn()
  if s:HasAnyFold()
    setlocal foldcolumn=1
  else
    setlocal foldcolumn=0
  endif
endfunction

augroup AutoFoldColumn
  autocmd!
  autocmd CursorHold,BufWinEnter,WinEnter * call s:AutoFoldColumn()
augroup END
