" --- tmux-aware window navigation ---
if empty($TMUX)
  " inside plain terminal
  nnoremap <silent> <C-h> <C-w>h
  nnoremap <silent> <C-j> <C-w>j
  nnoremap <silent> <C-k> <C-w>k
  nnoremap <silent> <C-l> <C-w>l

  " terminal-mode navigation
  tnoremap <silent> <C-w> <C-\><C-n><C-w>
  tnoremap <silent> <C-h> <C-\><C-n><C-w>h
  tnoremap <silent> <C-j> <C-\><C-n><C-w>j
  tnoremap <silent> <C-k> <C-\><C-n><C-w>k
  tnoremap <silent> <C-l> <C-\><C-n><C-w>l
  tnoremap <silent> <C-[> <C-\><C-n>
else
  " inside tmux, use vim-tmux-navigator plugin mappings
  nnoremap <silent> <C-h> <Cmd>TmuxNavigateLeft<CR>
  nnoremap <silent> <C-j> <Cmd>TmuxNavigateDown<CR>
  nnoremap <silent> <C-k> <Cmd>TmuxNavigateUp<CR>
  nnoremap <silent> <C-l> <Cmd>TmuxNavigateRight<CR>

  tnoremap <silent> <C-w> <C-\><C-n><C-w>
  tnoremap <silent> <C-h> <C-\><C-n><Cmd>TmuxNavigateLeft<CR>
  tnoremap <silent> <C-j> <C-\><C-n><Cmd>TmuxNavigateDown<CR>
  tnoremap <silent> <C-k> <C-\><C-n><Cmd>TmuxNavigateUp<CR>
  tnoremap <silent> <C-l> <C-\><C-n><Cmd>TmuxNavigateRight<CR>
  tnoremap <silent> <C-[> <C-\><C-n>
endif
