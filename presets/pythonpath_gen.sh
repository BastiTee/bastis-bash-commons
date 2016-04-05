#!/bin/bash

PYTHON_INSTALL="C:\\development\\\bin\\python-2.7.11-x64\\"
GITHUB_BASE="C:\\development\\\repos\github\\"
SEP=";"

echo
printf "${PYTHON_INSTALL}${SEP}"
for sub in DLLs Lib Lib\\lib-tk Lib\\site-packages
do
    printf "${PYTHON_INSTALL}\\${sub}${SEP}"
done
for sub in bastis-python-toolbox Chessnut chesster lazyscan pyntrest
do
    printf "${GITHUB_BASE}\\${sub}${SEP}"
done
echo
