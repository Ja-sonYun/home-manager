nnoremap <buffer><nowait> q <Cmd>q<CR>
nnoremap <buffer><nowait> <C-c> <Cmd>q<CR>
nnoremap <buffer><nowait> r <Cmd>e<CR>

setlocal signcolumn=no
setlocal bufhidden=wipe
setlocal nonumber norelativenumber
setlocal cursorline

let &l:listchars = join([
      \ 'tab:. ',
      \ 'extends:❯',
      \ 'precedes:❮',
      \ 'nbsp: ',
      \ 'trail: ',
      \ 'leadmultispace:| '
      \ ], ',')

wincmd J
vertical resize
resize 20

setlocal winfixheight winfixwidth
