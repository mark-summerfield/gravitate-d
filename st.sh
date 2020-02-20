tokei -s lines -f -t=D -e tests
dscanner --styleCheck \
    | grep -v Public.declaration.*is.undocumented \
    | grep -v gamewindow.d.*Variable.kv.is.never.modified \
    | grep -v board.d.*Variable.event[XY].is.never.modified
git status
