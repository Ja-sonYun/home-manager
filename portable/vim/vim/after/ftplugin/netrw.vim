setlocal signcolumn=no
setlocal bufhidden=wipe
setlocal nonumber norelativenumber signcolumn=no

nmap <buffer> l <CR>
nmap <buffer> h -
nmap <buffer> a %
nmap <buffer> m R
nmap <buffer> r :e . <bar> echo 'Reloaded.'<CR>
nmap <buffer> t <Nop>
nmap <buffer> v v$h

nmap <buffer><nowait><silent> q         :Rex<CR>
nmap <buffer><nowait><silent> <C-c>     :Rex<CR>
nmap <buffer><nowait><silent> <leader>f :Rex<CR>

nnoremap <buffer> <nowait> <silent> <C-h> :TmuxNavigateLeft<CR>
nnoremap <buffer> <nowait> <silent> <C-j> :TmuxNavigateDown<CR>
nnoremap <buffer> <nowait> <silent> <C-k> :TmuxNavigateUp<CR>
nnoremap <buffer> <nowait> <silent> <C-l> :TmuxNavigateRight<CR>
