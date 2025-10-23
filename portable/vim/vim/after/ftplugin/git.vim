nnoremap <buffer> <nowait> q <Cmd>q<CR>
nnoremap <buffer> <nowait> <C-c> <Cmd>q<CR>

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
