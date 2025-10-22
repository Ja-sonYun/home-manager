function! script#Setup(name, script) abort
  let l:tmp = tempname()
  let l:scripts = ['#!/bin/bash', 'set -e']

  call extend(l:scripts, a:script)
  call writefile(l:scripts, l:tmp)
  call system('chmod +x ' . shellescape(l:tmp))

  return l:tmp
endfunction
