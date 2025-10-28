if exists("g:loaded_user_fugitive")
  finish
endif
let g:loaded_user_fugitive = 1

nnoremap <silent> <leader>gg <Cmd>Git<CR>
nnoremap <silent> <leader>gb <Cmd>Git blame<CR>
nnoremap <silent> <leader>gd <Cmd>Git diff<CR>
