if exists("g:loaded_user_formatter")
  finish
endif
let g:loaded_user_formatter = 1

command! -nargs=1 Formatter call fmt#Formatter(<q-args>)

" Formatter
function! s:Fmt() abort
  " Keep cursor position
  let v = winsaveview()
  normal! ggVGgq
  call winrestview(v)
endfunction

nnoremap <silent><nowait> gq <Cmd>call <SID>Fmt()<CR>
