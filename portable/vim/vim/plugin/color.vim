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
