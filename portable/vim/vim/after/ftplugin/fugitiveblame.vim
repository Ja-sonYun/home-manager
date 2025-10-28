if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

setlocal cursorline

nmap <buffer> l <CR>
nnoremap <buffer><nowait> q <Cmd>q<CR>
nnoremap <buffer><nowait> <C-c> <Cmd>q<CR>
nnoremap <buffer> <leader>f <Nop>
