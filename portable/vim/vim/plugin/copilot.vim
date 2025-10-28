if exists("g:loaded_user_copilot")
  finish
endif
let g:loaded_user_copilot = 1

inoremap <expr> <C-s> copilot#Accept("\<CR>")

let g:copilot_no_tab_map = v:true
let g:copilot_filetypes = { '*' : v:true }
