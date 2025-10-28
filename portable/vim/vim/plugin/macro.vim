vim9script

if exists('g:loaded_user_macro')
  finish
endif
g:loaded_user_macro = true

import autoload 'macro/core.vim'

core.Setup()
