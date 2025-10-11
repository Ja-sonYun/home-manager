" Default color scheme, but improved for better readability

hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "default-ir"

function! s:FixMissingCtermFg()
  for g in getcompletion('', 'highlight')
    let id = hlID(g)
    let fg = synIDattr(id, 'fg', 'cterm')
    let bg = synIDattr(id, 'bg', 'cterm')
    if (fg == '' || fg == -1) && (bg != '' && bg != -1)
      execute 'hi ' . g . ' ctermfg=0'
    endif
  endfor
endfunction

call s:FixMissingCtermFg()
