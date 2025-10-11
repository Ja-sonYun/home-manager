vim9script

augroup YankHighlight
  autocmd!
  autocmd TextYankPost * call OnYank()
augroup END

def OnYank()
  if get(v:event, 'operator', '') !=# 'y'
    return
  endif

  var sl = getpos("'[")[1]
  var sc = getpos("'[")[2]
  var el = getpos("']")[1]
  var ec = getpos("']")[2]
  if sl <= 0 || el <= 0
    return
  endif

  var pos: list<any> = []
  if sl == el
    add(pos, [sl, sc, max([1, ec - sc])])
  else
    add(pos, [sl, sc, 9999])
    if el - sl > 1
      for L in range(sl + 1, el - 1)
        add(pos, [L])
      endfor
    endif
    add(pos, [el, 1, max([1, ec - 1])])
  endif

  var id = matchaddpos('IncSearch', pos, 10)
  call timer_start(1000, (-> matchdelete(id)))
enddef
