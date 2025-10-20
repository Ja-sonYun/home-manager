let g:netrw_preview = 1
let g:netrw_use_errorwindow = 0
let g:netrw_winsize = 30
let g:netrw_fastbrowse = 0
let g:netrw_keepdir = 0
let g:netrw_liststyle = 0
let g:netrw_special_syntax = 1

let s:header_lines = 8

augroup OverrideExplore
  autocmd!
  autocmd VimEnter * call s:OverrideExplore()
augroup END

function! s:OverrideExplore() abort
  silent! delcommand Explore
  command! -nargs=* -complete=dir Explore call s:Explore(<q-args>)
endfunction

function! s:Explore(args) abort
  if &buftype == '' && &filetype !=# 'netrw'
    let l:file = expand('%:t')
    let l:dir  = expand('%:p:h')
  else
    let l:file = ''
    let l:dir  = getcwd()
  endif

  if a:args ==# ''
    call netrw#Explore(0, 0, 0, fnameescape(l:dir))
  else
    call netrw#Explore(0, 0, 0, a:args)
  endif

  if l:file ==# ''
    return
  endif
  if search('\V' . escape(l:file, '\'), 'w') == 0
    call cursor(s:header_lines + 1, 1)
  endif
endfunction

nnoremap <silent> <leader>f :Explore<CR>
