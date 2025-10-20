vim9script

export def DeepMerge(to: dict<any>, from: dict<any>): dict<any>
  for [k, v] in items(from)
    if has_key(to, k) && type(to[k]) == v:t_dict && type(v) == v:t_dict
      DeepMerge(to[k], v)
    else
      to[k] = deepcopy(v)
    endif
  endfor
  return to
enddef
