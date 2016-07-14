@echo off

cd %~dp0

echo Creating links in %APPDATA%\Sublime Text 3\Packages\User

MKLINK "%APPDATA%\Sublime Text 3\Packages\User\Default (Windows).sublime-keymap" "%~dp0\Default (Windows).sublime-keymap" 
MKLINK "%APPDATA%\Sublime Text 3\Packages\User\Default (Windows).sublime-mousemap" "%~dp0\Default (Windows).sublime-mousemap" 
MKLINK "%APPDATA%\Sublime Text 3\Packages\User\Preferences.sublime-settings" "%~dp0\Preferences.sublime-settings" 
MKLINK "%APPDATA%\Sublime Text 3\Packages\User\Default.sublime-theme" "%~dp0\Default.sublime-theme" 
MKLINK "%APPDATA%\Sublime Text 3\Packages\User\Default.sublime-snippet" "%~dp0\Default.sublime-snippet"
