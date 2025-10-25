setlocal signcolumn=no
setlocal bufhidden=wipe
setlocal nonumber norelativenumber signcolumn=no

nmap <buffer> l <CR>
nmap <buffer> h -
nmap <buffer> a %
nmap <buffer> m R
nmap <buffer> r <Cmd>e . <bar> echo 'Reloaded.'<CR>
nmap <buffer> t <Nop>
nmap <buffer> v v$h
nmap <buffer> b qb
nmap <buffer> f qf
nmap <buffer> F qF
nmap <buffer> L qL

nmap <buffer> s <Nop>

nmap <buffer><nowait><silent> q         <Cmd>Rex<CR>
nmap <buffer><nowait><silent> <C-c>     <Cmd>Rex<CR>
nmap <buffer><nowait><silent> <leader>f <Cmd>Rex<CR>

nnoremap <buffer> <nowait> <silent> <C-h> <Cmd>TmuxNavigateLeft<CR>
nnoremap <buffer> <nowait> <silent> <C-j> <Cmd>TmuxNavigateDown<CR>
nnoremap <buffer> <nowait> <silent> <C-k> <Cmd>TmuxNavigateUp<CR>
nnoremap <buffer> <nowait> <silent> <C-l> <Cmd>TmuxNavigateRight<CR>
