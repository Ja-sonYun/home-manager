setlocal nonumber
setlocal cursorline
setlocal statusline=%n\ %f%=%L\ lines

nnoremap <buffer> <nowait> q :q<CR>
nnoremap <buffer> <nowait> <C-c> :q<CR>
nnoremap <buffer> <nowait> l <CR>:wincmd p<CR>

wincmd J
vertical resize
resize 10
