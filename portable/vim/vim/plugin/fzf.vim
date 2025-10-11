if exists('$FZF_DEFAULT_OPTS')
  let $FZF_DEFAULT_OPTS = $FZF_DEFAULT_OPTS . ' --multi --bind ctrl-s:select-all,ctrl-d:deselect-all'
else
  let $FZF_DEFAULT_OPTS = '--multi --bind ctrl-s:select-all,ctrl-d:deselect-all'
endif

let g:fzf_layout = { 'down': '20%' }

nnoremap <silent> <space>f :Files<CR>
nnoremap <silent> <space>r :Rg<CR>
nnoremap <silent> <space>b :Buffers<CR>

augroup Fzf
  autocmd!
  autocmd FileType fzf nnoremap <buffer> <nowait> q :q<CR>
  autocmd FileType fzf nnoremap <buffer> <nowait> <C-c> :q<CR>
augroup END

autocmd! FileType fzf set laststatus=0 noshowmode noruler |
      \ autocmd BufLeave <buffer> set laststatus=2 showmode ruler
