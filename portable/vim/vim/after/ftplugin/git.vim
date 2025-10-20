nnoremap <buffer> <nowait> q :q<CR>
nnoremap <buffer> <nowait> <C-c> :q<CR>

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
