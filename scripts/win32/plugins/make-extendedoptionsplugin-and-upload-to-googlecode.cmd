@echo off
@echo Cloning Extended Options Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/extendedoptionsplugin psi\src\plugins\generic\extendedoptionsplugin
@echo Completed
@echo Building Extended Options Plugin
cd psi\src\plugins\generic\extendedoptionsplugin
call qmake extendedoptionsplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Extended Options Plugin to work dir
copy release\extendedoptionsplugin.dll "%PSIPLUSDIR%\plugins\extendedoptionsplugin.dll" /Y
pause
@echo Archiving Extended Options Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-extendedoptionsplugin-0.3.2-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\extendedoptionsplugin.dll"
@echo Completed
@echo Uploading archived Extended Options Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Extended Options Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-extendedoptionsplugin-0.3.2-win32.zip"
@echo Completed
pause & pause
