@ECHO OFF
REM ============================================================================
REM WIN-RUNNER.BAT (BASTI's BASH COMMONS)
REM A windows batch file that runs a shell script with the same name and .sh 
REM suffix in the same folder over mintty, e.g., win-runner.bat invokes 
REM win-runner.sh in a mintty shell. 
REM 
REM Licensed under the Apache License, Version 2.0 (the "License");
REM ============================================================================

SET BABUNBIN=%USERPROFILE%\.babun\cygwin\bin\mintty.exe
ECHO Testing babun installation at %BABUNBIN%...
IF NOT EXIST %BABUNBIN% (
    ECHO Babun not found. Will exit.
    PAUSE
    EXIT /B 1
) ELSE (
    ECHO Babun installation found.
)
FOR /f %%i in ('%USERPROFILE%\.babun\cygwin\bin\cygpath.exe -ua .') ^
DO SET FULL_CYGPATH=%%i
SET SHELLSCRIPT=%FULL_CYGPATH%%~n0.sh
FOR /f %%i in ('%USERPROFILE%\.babun\cygwin\bin\cygpath.exe -w %SHELLSCRIPT%') ^
DO SET SHELLSCRIPTDOS=%%i
ECHO Batch file located in %FULL_CYGPATH% with name %~n0
ECHO Testing shellscript at %SHELLSCRIPTDOS%
IF NOT EXIST %SHELLSCRIPTDOS% (
    ECHO Shellscript not found. Will exit.
    PAUSE
    EXIT /B 1
) ELSE (
    ECHO Shell script found.
)
start /HIGH /B %BABUNBIN% --hold error /bin/bash -l  -e %SHELLSCRIPT%
