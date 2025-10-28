vim9script

if exists('g:loaded_user_f')
  finish
endif
g:loaded_user_f = true

import autoload 'f/core.vim'

core.Setup()
