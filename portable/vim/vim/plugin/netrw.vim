vim9script

g:netrw_preview = 1
g:netrw_use_errorwindow = 0
g:netrw_winsize = 30
g:netrw_fastbrowse = 0
g:netrw_keepdir = 0
g:netrw_liststyle = 0
g:netrw_special_syntax = 1

def g:OpenNetrw(): void
  if &filetype !=# 'netrw'
    execute 'Explore'
  endif
enddef

nnoremap <silent> <leader>f <Cmd>call g:OpenNetrw()<CR>
