" --- Don't auto-comment new lines ---
augroup NoAutoComment
  autocmd!
  autocmd BufEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END


" --- Remove trailing whitespace on save ---
" now only runs if `b:do_trim_trail` exists and true
augroup TrimTrailingWS
  autocmd!
  autocmd BufWritePre * if get(b:, 'do_trim_trail', 0) | silent! %s/\s\+$//e | endif
augroup END


" --- Always switch Rel/Abs number automatically ---
augroup ModifyRelativeNumber
  autocmd!
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave,CmdlineEnter *
        \ setlocal norelativenumber
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter,CmdlineLeave *
        \ setlocal number relativenumber
augroup END

" --- Open file at last edit position ---
augroup OpenFileAtLastPosition
  autocmd!
  autocmd BufReadPost * silent! normal! g`"zv
augroup END


" --- Dynamic on-save hook via environment variables ---
augroup OnSaveHook
  autocmd!
  autocmd BufWritePost * call s:MaybeRunOnSaveHook()
augroup END

function! s:FileMatchesGlobs(globs, fname) abort
  for pat in split(a:globs, ',')
    if a:fname =~ glob2regpat(pat)
      return 1
    endif
  endfor
  return 0
endfunction

function! s:MaybeRunOnSaveHook() abort
  if empty($VIM_ON_SAVE_HOOK)
    return
  endif
  let l:f = expand('%:t')
  if empty($VIM_ON_SAVE_HOOK_TRIGGER_RULES)
    call system($VIM_ON_SAVE_HOOK)
  elseif s:FileMatchesGlobs($VIM_ON_SAVE_HOOK_TRIGGER_RULES, l:f)
    call system($VIM_ON_SAVE_HOOK)
  endif
endfunction
