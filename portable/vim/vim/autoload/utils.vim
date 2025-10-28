function! utils#Preserve(cmd) abort
  let view = winsaveview()
  execute a:cmd
  call winrestview(view)
endfunction
