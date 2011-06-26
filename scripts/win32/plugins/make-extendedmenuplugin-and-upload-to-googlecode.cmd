@echo off
@echo Cloning Extended Menu Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/extendedmenuplugin psi\src\plugins\generic\extendedmenuplugin
@echo Completed
@echo Building Extended Menu Plugin
cd psi\src\plugins\generic\extendedmenuplugin
call qmake extendedmenuplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Extended Menu Plugin
copy release\extendedmenuplugin.dll "%PSIPLUSDIR%\plugins\extendedmenuplugin.dll" /Y
pause
@echo Archiving Extended Menu Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-extendedmenuplugin-0.0.7-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\extendedmenuplugin.dll"
@echo Completed
@echo Uploading archived Extended Menu Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Extended Menu Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-extendedmenuplugin-0.0.7-win32.zip"
@echo Completed
pause & pause
