vim9script

if exists('g:loaded_user_mark')
  finish
endif
g:loaded_user_mark = true

import autoload 'vmark/core.vim'

core.Setup()
