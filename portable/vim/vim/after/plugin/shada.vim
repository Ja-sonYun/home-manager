" " Per-workspace viminfo file
" set exrc
" set secure

" let ws   = getcwd()
" let base = fnamemodify(ws, ':t')
" let hash = strpart(sha256(ws), 0, 8)
" let home = expand('~')
" let dir  = home . '/.local/share/vim/shada/' . base
" call mkdir(dir, 'p')

" let file = dir . '/' . base . '_' . hash . '.viminfo'

" if exists('&viminfofile')
"   let &viminfofile = file
" else
"   let vinfo = &viminfo
"   let vinfo = substitute(vinfo, ',\?n[^,]*$', '', '')
"   let &viminfo = vinfo . ',n' . file
" endif

" silent! wviminfo!
