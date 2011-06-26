@echo off
@echo Cloning Translate Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/translateplugin psi\src\plugins\generic\translateplugin
@echo Completed
@echo Building Translate Plugin
cd psi\src\plugins\generic\translateplugin
call qmake translateplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Translate Plugin to work dir
copy release\translateplugin.dll "%PSIPLUSDIR%\plugins\translateplugin.dll" /Y
pause
@echo Archiving Translate Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-translateplugin-0.3.2-win32.zip" "%PSIPLUSDIR%\plugins\translateplugin.dll"
@echo Completed
@echo Uploading archived Translate Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Translate Plugin for Psi+ || Qt 4.7.1" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-translateplugin-0.3.2-win32.zip"
@echo Completed
pause & pause
