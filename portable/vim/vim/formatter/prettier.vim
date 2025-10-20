let ext = tolower(expand('%:e'))
if empty(ext)
  let ext = &l:filetype
endif

let &l:formatexpr = printf('fmt#RunFmt("%s", [''prettier --write {file}''])', ext)
