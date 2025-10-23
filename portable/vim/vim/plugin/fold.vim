vim9script

def FoldPluginHasAnyFold(): bool
  for lnum in range(1, line('$'))
    if foldlevel(lnum) > 0
      return true
    endif
  endfor
  return false
enddef

def FoldPluginAutoFoldColumn()
  if FoldPluginHasAnyFold()
    &l:foldcolumn = 1
  else
    &l:foldcolumn = 0
  endif
enddef

augroup AutoFoldColumn
  autocmd!
  autocmd CursorHold,BufWinEnter,WinEnter * FoldPluginAutoFoldColumn()
augroup END

defcompile
