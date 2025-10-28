vim9script

if exists('g:loaded_user_yankhighlight')
  finish
endif
g:loaded_user_yankhighlight = true

def HighlightedYank(hlgroup = 'IncSearch', duration = 1000, in_visual = true)
  if v:event.operator !=? 'y'
    return
  endif

  if !in_visual && visualmode() != null_string
    visualmode(1)
    return
  endif

  if &clipboard =~ 'autoselect' && v:event.regname == "*" && v:event.visual
    return
  endif

  var beg = getpos("'[")
  var fin = getpos("']")
  if beg[1] <= 0 || fin[1] <= 0
    return
  endif

  var type = v:event.regtype ?? 'v'
  var segs = getregionpos(beg, fin, { type: type, exclusive: false })
  if empty(segs)
    return
  endif

  var id = matchaddpos(hlgroup, mapnew(segs, (_, s) => {
    var col_beg = s[0][2] + s[0][3]
    var col_end = s[1][2] + s[1][3] + 1
    return [s[0][1], col_beg, col_end - col_beg]
  }))

  if id > 0
    var ms = min([duration, 3000])
    var winid = win_getid()
    timer_start(ms, (_) => matchdelete(id, winid))
  endif
enddef

augroup YankHighlight
  autocmd!
  autocmd TextYankPost * HighlightedYank()
augroup END

defcompile
