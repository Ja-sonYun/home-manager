if exists("g:loaded_user_formatter")
  finish
endif
let g:loaded_user_formatter = 1

command! -nargs=1 Formatter call fmt#Formatter(<q-args>)
