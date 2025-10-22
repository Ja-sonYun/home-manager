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

highlight StatusLineTerm term=bold,reverse cterm=bold ctermfg=0 ctermbg=2 gui=bold guifg=bg guibg=DarkGreen
highlight StatusLineTermNC term=reverse ctermfg=0 ctermbg=2 guifg=bg guibg=DarkGreen
highlight SignColumn term=standout ctermfg=4 ctermbg=0 guifg=DarkBlue guibg=Black

highlight link diffAdded       MatchParen
highlight link diffChanged     WarningMsg
highlight link diffRemoved     ErrorMsg

" GitGutter highlights
highlight GitGutterAdd    ctermfg=2
highlight GitGutterChange ctermfg=3
highlight GitGutterDelete ctermfg=1

highlight Folded     term=standout ctermfg=4 ctermbg=0 guifg=DarkBlue guibg=Black
highlight FoldColumn term=standout ctermfg=4 ctermbg=0 guifg=DarkBlue guibg=Black
