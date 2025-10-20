let ext = &l:filetype ==# 'cpp' ? 'cpp' : 'c'

let &l:formatexpr = printf('fmt#RunFmt("%s", [''clang-format -i {file}''])', ext)
