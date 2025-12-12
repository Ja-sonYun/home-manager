if exists("g:loaded_user_eskk")
  finish
endif
let g:loaded_user_eskk = 1

let g:eskk#enable_completion = 1
let g:eskk#start_completion_length = 2
let g:eskk#tab_select_completion = 1

let s:saved_mappings = {}

autocmd User eskk-enable-post call s:eskk_enable_post()
autocmd User eskk-disable-post call s:eskk_disable_post()

function! s:eskk_enable_post() abort
  let s:saved_mappings['Space'] = maparg('<Space>', 'i', 0, 1)
  inoremap <buffer> <expr> <Space> <SID>eskk_space()
endfunction

function! s:eskk_space() abort
  if pumvisible()
    return "\<C-n>"
  else
    return "\<C-x>\<C-o>"
  endif
endfunction

function! s:eskk_disable_post() abort
  silent! iunmap <buffer> <Space>
  if !empty(s:saved_mappings['Space'])
    call s:restore_mapping(s:saved_mappings['Space'])
  endif
endfunction

function! s:restore_mapping(map) abort
  if empty(a:map)
    return
  endif
  let cmd = a:map.noremap ? 'inoremap' : 'imap'
  let buf = a:map.buffer ? '<buffer>' : ''
  let silent = a:map.silent ? '<silent>' : ''
  let expr = a:map.expr ? '<expr>' : ''
  let lhs = a:map.lhs
  let rhs = a:map.rhs
  execute cmd buf silent expr lhs rhs
endfunction
