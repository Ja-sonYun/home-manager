vim9script

if exists('g:loaded_user_terminal')
  finish
endif
g:loaded_user_terminal = true

import autoload 'terminal/core.vim'

core.Setup()

nnoremap <leader>e :Sh 
nnoremap <leader>c :Make 
