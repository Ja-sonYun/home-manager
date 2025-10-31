nnoremap <buffer> <leader>f <Nop>

setlocal signcolumn=no
setlocal bufhidden=wipe
setlocal nonumber norelativenumber

let &l:listchars = join([
      \ 'tab:. ',
      \ 'extends:❯',
      \ 'precedes:❮',
      \ 'nbsp: ',
      \ 'trail: ',
      \ 'leadmultispace:| '
      \ ], ',')
