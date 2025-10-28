if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetPrismaIndent(v:lnum)
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e

function! GetPrismaIndent(lnum)
  " First line: no indent
  if a:lnum == 1
    return 0
  endif

  " Current and previous lines
  let line = getline(a:lnum)
  let prev_lnum = prevnonblank(a:lnum - 1)
  if prev_lnum == 0
    return 0
  endif
  let prev_line = getline(prev_lnum)
  let prev_indent = indent(prev_lnum)

  " Look upward until matching '{' to align with its indent
  if line =~ '^\s*}'
    " Search backward for the nearest line containing '{'
    let match_lnum = search('{', 'bnW')
    if match_lnum > 0
      return indent(match_lnum)
    else
      return prev_indent - &shiftwidth
    endif
  endif

  " Handle opening brace
  if prev_line =~ '{\s*$'
    return prev_indent + &shiftwidth
  endif

  " Comments keep same indent
  if line =~ '^\s*//'
    return prev_indent
  endif

  if prev_line =~ '^\s*//' || prev_line =~ '^\s*$'
    return prev_indent
  endif

  " Default: keep previous indent
  return prev_indent
endfunction
