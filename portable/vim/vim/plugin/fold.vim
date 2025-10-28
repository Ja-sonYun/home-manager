vim9script

if exists('g:loaded_user_fold')
  finish
endif
g:loaded_user_fold = true

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
