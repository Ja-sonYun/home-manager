if exists("g:loaded_user_tag")
  finish
endif
let g:loaded_user_tag = 1

nnoremap <silent> <leader>t <Cmd>TagbarToggle<CR>
