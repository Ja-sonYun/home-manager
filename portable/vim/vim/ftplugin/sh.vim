if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let b:indent = 4
let b:autorel = 1
let b:trimtrail = v:true

Formatter shfmt
