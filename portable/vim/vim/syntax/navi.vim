if exists("b:current_syntax")
  finish
endif

syntax match Comment "\v^;.*$"
syntax match Statement "\v^\%.*$"
syntax match Operator "\v^\#.*$"
syntax match String "\v\<.*\>"
syntax match String "\v^\$.*$"

let b:current_syntax = "navi"
