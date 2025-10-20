let &l:formatexpr = 'fmt#RunFmt("awk", [''awk --pretty-print={file}.tmp -f {file} && mv {file}.tmp {file}''])'
