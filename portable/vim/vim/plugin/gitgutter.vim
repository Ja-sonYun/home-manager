if exists("g:loaded_user_gitgutter")
  finish
endif
let g:loaded_user_gitgutter = 1

let g:gitgutter_map_keys = 0
let g:gitgutter_set_sign_backgrounds = 1
let g:gitgutter_preview_win_floating = 1

let g:gitgutter_sign_added = '|'
let g:gitgutter_sign_modified = '|'
let g:gitgutter_sign_removed = '|'
let g:gitgutter_sign_removed_first_line = '|'
let g:gitgutter_sign_removed_above_and_below = '|'
let g:gitgutter_sign_modified_removed = '|'

nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap H  <Plug>(GitGutterPreviewHunk)

nmap ghs <Plug>(GitGutterStageHunk)
nmap ghr <Plug>(GitGutterUndoHunk)
