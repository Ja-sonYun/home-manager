setlocal nonumber
setlocal cursorline
setlocal statusline=%n\ %f%=%L\ lines

nnoremap <buffer><silent><nowait> q :q<CR>
nnoremap <buffer><silent><nowait> <C-c> :q<CR>
nnoremap <buffer><silent><nowait> l <CR>:wincmd p<CR>

nnoremap <buffer><nowait> cf :Cfilter 
nnoremap <buffer><nowait> cf! :Cfilter! 

wincmd J
vertical resize
resize 10
