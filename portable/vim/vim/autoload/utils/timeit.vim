vim9script

export def TimeIt(Fn: func, ...args: list<any>): void
  const t0 = reltime()
  call(Fn, args)
  const elapsed = reltimestr(reltime(t0))
  echomsg printf('Time: %s', elapsed)
enddef
