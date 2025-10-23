command! -nargs=1 Formatter call fmt#Formatter(<q-args>)

" Formatter
function! s:Fmt() abort
  " Keep cursor position
  let v = winsaveview()
  normal! ggVGgq
  call winrestview(v)
endfunction

nnoremap <silent><nowait> gq <Cmd>call <SID>Fmt()<CR>
