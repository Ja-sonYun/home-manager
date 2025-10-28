vim9script

if exists('g:loaded_user_quickfix')
  finish
endif
g:loaded_user_quickfix = true

import autoload 'bnqf/core.vim'

core.Setup()
