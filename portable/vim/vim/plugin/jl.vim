function! s:NextFileJump(forward) abort
  let start = expand('%:p')
  let max = 100

  for _ in range(max)
    if a:forward
      call feedkeys("\<C-i>", 'n')
    else
      call feedkeys("\<C-o>", 'n')
    endif
    redraw

    if expand('%:p') !=# start && &buftype ==# '' && &modifiable && !&readonly
      return
    endif
  endfor
endfunction

nnoremap <silent> <Space>i <Cmd>call <SID>NextFileJump(1)<CR>
nnoremap <silent> <Space>o <Cmd>call <SID>NextFileJump(0)<CR>
