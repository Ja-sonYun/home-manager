if exists("g:loaded_user_commentary")
  finish
endif
let g:loaded_user_commentary = 1

vmap \c<Space> <Plug>Commentary
nmap \c<Space> <Plug>CommentaryLine
