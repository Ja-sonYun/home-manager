let g:usercomplete = []

function! UserListComplete(findstart, base) abort
  if a:findstart
    let l:line = getline('.')
    let l:start = col('.') - 1
    while l:start > 0 && l:line[l:start - 1] =~ '\k'
      let l:start -= 1
    endwhile
    return l:start
  else
    let l:src = get(b:, 'usercomplete', get(g:, 'usercomplete', []))
    let l:pat = '^' . escape(a:base, '\')
    let l:cands = filter(copy(l:src), {_, v -> v =~ l:pat})
    return uniq(sort(l:cands))
  endif
endfunction

set completefunc=UserListComplete
