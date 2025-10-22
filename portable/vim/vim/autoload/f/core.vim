vim9script

g:last_char = ''
g:last_dir  = 1

def DoMove(forward: bool, isVisual: bool): void
  var c = g:last_char
  var lnum = line('.')
  var pos = col('.')
  var found: bool = false
  var idx: number  = -1

  if forward
    while lnum <= line('$')
      var txt   = getline(lnum)
      var start = (lnum == line('.')) ? pos : 0
      idx = stridx(txt, c, start)
      if idx >= 0
        found = true
        break
      endif
      lnum += 1
    endwhile
  else
    while lnum >= 1
      var txt = getline(lnum)
      var stopcol = (lnum == line('.')) ? pos - 2 : strlen(txt)
      if stopcol < 0
        stopcol = strlen(txt)
      endif
      idx = strridx(txt[0 : stopcol], c)
      if idx >= 0
        found = true
        break
      endif
      lnum -= 1
    endwhile
  endif

  if !found
    echom 'not found: ' .. c
    return
  endif

  if isVisual
    var vpos = getpos('v')
    var vline = vpos[1]
    var vcol = vpos[2]
    var seq = '' .. vline .. 'G0' .. (vcol - 1) .. 'l' .. 'v' .. lnum .. 'G0' .. idx .. 'l'
    feedkeys(seq, 'nx')
  else
    cursor(lnum, idx + 1)
  endif
enddef

def StartMove(forward: bool, isVisual: bool): void
  var c = nr2char(getchar())
  if c ==# "\<Esc>"
    return
  endif
  g:last_char = c
  g:last_dir  = forward ? 1 : -1
  DoMove(forward, isVisual)
enddef

def RepeatMove(reverse: bool, isVisual: bool): void
  if g:last_char ==# ''
    echom 'no previous f/F search'
    return
  endif
  var dir = reverse ? -g:last_dir : g:last_dir
  DoMove(dir == 1, isVisual)
enddef

export def Setup(): void
  nnoremap <silent> f <ScriptCmd>StartMove(1, 0)<CR>
  nnoremap <silent> F <ScriptCmd>StartMove(0, 0)<CR>
  nnoremap <silent> ; <ScriptCmd>RepeatMove(0, 0)<CR>
  nnoremap <silent> <leader>, <ScriptCmd>RepeatMove(1, 0)<CR>

  xnoremap <silent> f <ScriptCmd>StartMove(1, 1)<CR>
  xnoremap <silent> F <ScriptCmd>StartMove(0, 1)<CR>
  xnoremap <silent> ; <ScriptCmd>RepeatMove(0, 1)<CR>
  xnoremap <silent> <leader>, <ScriptCmd>RepeatMove(1, 1)<CR>
enddef

defcompile
