tokei -s lines -f -t=D -e tests -e icons.d
dscanner --styleCheck \
    | grep -v Public.declaration.*is.undocumented \
    | grep -v gamewindow.d.*Variable.kv.is.never.modified \
    | grep -v helpform.d.*Variable.kv.is.never.modified \
    | grep -v optionsform.d.*Variable.kv.is.never.modified \
    | grep -v gamewindow.d.*Variable.[ab].is.never.modified \
    | grep -v board.d.*Variable.event[XY].is.never.modified \
    | grep -v helpform.d.*Line.is.longer.than.*characters \
    | grep -v icons.d.*Line.is.longer.than.*characters
git status
