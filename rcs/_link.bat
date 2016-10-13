@echo off
SETLOCAL
ECHO Checking permissions.
NET session >NUL 2>&1
IF %ERRORLEVEL% == 0 (
    ECHO Administrative permissions confirmed.
) ELSE (
    ECHO Current permissions inadequate.
    ECHO You must run this script as administrator.
    GOTO :EOF
)
    
CD %~dp0
FOR %%F IN (babunrc gitconfig vimrc) ^
DO (call :HANDLER %%F)
GOTO :EOF

:HANDLER
    SET SRCFILE="%~dp0%1"
    SET TRGFILE="%USERPROFILE%\.babun\cygwin\home\%USERNAME%\.%1"
    ECHO Trying to link %SRCFILE% to  %TRGFILE%
	DEL %TRGFILE%
    MKLINK %TRGFILE% %SRCFILE% 
    GOTO :EOF

:EOF
ENDLOCAL
