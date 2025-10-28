if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

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
