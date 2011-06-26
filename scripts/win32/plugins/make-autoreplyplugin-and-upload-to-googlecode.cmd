@echo off
@echo Cloning Autoreply Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/autoreplyplugin psi\src\plugins\generic\autoreplyplugin
@echo Completed
@echo Building Autoreply Plugin
cd psi\src\plugins\generic\autoreplyplugin
call qmake autoreplyplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Autoreply Plugin
copy release\autoreplyplugin.dll "%PSIPLUSDIR%\plugins\autoreplyplugin.dll" /Y
pause
@echo Archiving Autoreply Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-autoreplyplugin-0.3.0-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\autoreplyplugin.dll"
@echo Completed
@echo Uploading archived Autoreply Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Autoreply Plugin for Psi+ || Qt 4.7.0 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-autoreplyplugin-0.3.0-win32.zip"
@echo Completed
pause & pause
