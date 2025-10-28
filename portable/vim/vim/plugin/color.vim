if exists("g:loaded_user_color")
  finish
endif
let g:loaded_user_color = 1

function! ShowCtermColors(bg)
  " bg = 0 -> foreground colors
  " bg = 1 -> background colors
  for i in range(0, 255)
    if a:bg
      execute 'hi Col'.i.' ctermbg='.i
      execute 'echohl Col'.i | echon printf('%3d ', i) | echohl None
    else
      execute 'hi Col'.i.' ctermfg='.i
      execute 'echohl Col'.i | echon printf('%3d ', i) | echohl None
    endif
    if (i + 1) % 16 == 0
      echo ''
    endif
  endfor
endfunction
