if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let b:indent = 2
let b:autorel = 1
let b:usetab = v:true
let b:trimtrail = v:true

Formatter bake
