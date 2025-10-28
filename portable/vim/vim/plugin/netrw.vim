if exists("g:loaded_user_netrw")
  finish
endif
let g:loaded_user_netrw = 1

let g:netrw_preview = 1
let g:netrw_use_errorwindow = 0
let g:netrw_winsize = 30
let g:netrw_fastbrowse = 0
let g:netrw_keepdir = 0
let g:netrw_liststyle = 0
let g:netrw_special_syntax = 1

nnoremap <silent> <leader>f <Cmd>Explore<CR>
