if exists('*netrw#BrowseX')
  delfunction netrw#BrowseX
endif

function! netrw#BrowseX(url, ...) abort
  if has('mac')
    execute 'silent !open ' . shellescape(a:url)
  elseif has('win32') || has('win64')
    execute 'silent !start "" ' . shellescape(a:url)
  elseif executable('xdg-open')
    execute 'silent !xdg-open ' . shellescape(a:url)
  elseif executable('gio')
    execute 'silent !gio open ' . shellescape(a:url)
  endif
  redraw!
  return 1
endfunction

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

  if l:file !=# '' && search('\V' . escape(l:file, '\'), 'w') == 0
    call cursor(s:header_lines + 1, 1)
  endif
endfunction

nnoremap <silent> <leader>f <Cmd>Explore<CR>
