vim9script

g:mark_signs_hl = get(g:, 'mark_signs_hl', 'Identifier')
g:mark_vt_align = get(g:, 'mark_vt_align', 'right')
var letters = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs')

def EnsureType(bufn: number)
  if empty(prop_type_get('MarkVT', {'bufnr': bufn}))
    call prop_type_add('MarkVT', {'bufnr': bufn, 'highlight': g:mark_signs_hl, 'priority': 10})
  endif
enddef

def SafeMarkLnum(letter: string, bufn: number): number
  var p = getpos("'" .. letter)
  if type(p) != v:t_list || len(p) < 3
    return 0
  endif
  var b = p[0]
  var l = p[1]
  if l <= 0 || l > line('$')
    return 0
  endif
  if b == 0 || b == bufn
    return l
  endif
  return 0
enddef

def ClearVT(bufn: number)
  call prop_remove({'bufnr': bufn, 'type': 'MarkVT', 'all': v:true})
enddef

def PlaceVT(letter: string, lnum: number, bufn: number)
  if g:mark_vt_align ==# 'left'
    call prop_add(lnum, 1, {'bufnr': bufn, 'type': 'MarkVT', 'text': letter})
  else
    call prop_add(lnum, 0, {'bufnr': bufn, 'type': 'MarkVT', 'text': letter, 'text_align': 'right'})
  endif
enddef

def SyncMark()
  var bn = bufnr('')
  call EnsureType(bn)
  call ClearVT(bn)
  for l in letters
    var ln = SafeMarkLnum(l, bn)
    if ln > 0
      call PlaceVT(l, ln, bn)
    endif
  endfor
enddef

export def Setup()
  augroup MarkVT
    autocmd!
    autocmd BufEnter * call SyncMark()
    autocmd CursorHold * call SyncMark()
  augroup END
enddef

defcompile
