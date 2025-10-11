vim9script

def g:GetScrollbar(): string
  var sbar_chars = ['▇', '▆', '▅', '▄', '▃', '▂', '▁']
  var cur_line = line('.')
  var total = line('$')
  if total <= 1
    return repeat(sbar_chars[-1], 2)
  endif
  var idx = float2nr(floor(((cur_line - 1.0) / total) * len(sbar_chars)))
  return repeat(sbar_chars[idx], 2)
enddef

def g:GetFileInfo(): string
  return exists('b:info') ? string(b:info) : ''
enddef

&statusline = '%<%f%h%m%r%{GetFileInfo()}%=%b 0x%B %l,%c%V %{GetScrollbar()} %P'
&laststatus = 2
