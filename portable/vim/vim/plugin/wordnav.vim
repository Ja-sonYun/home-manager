vim9script

if exists('g:loaded_user_wordnav')
  finish
endif
g:loaded_user_wordnav = true

import autoload 'wordnav/core.vim'

core.Setup({})
