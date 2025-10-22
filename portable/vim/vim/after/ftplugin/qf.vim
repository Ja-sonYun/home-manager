setlocal nonumber
setlocal cursorline
setlocal statusline=%n\ %f%=%L\ lines

nnoremap <buffer><silent><nowait> q :q<CR>
nnoremap <buffer><silent><nowait> <C-c> :q<CR>
nnoremap <buffer><silent><nowait> l <CR>:wincmd p<CR>

nnoremap <buffer><nowait> f :Cfilter 
nnoremap <buffer><nowait> F :Cfilter! 

function s:TabCC(line)
  execute 'tabnew'
  execute 'cc' a:line
endfunction

nnoremap <silent><buffer><nowait> t :call <SID>TabCC(line('.'))<CR>

wincmd J
vertical resize
resize 10
