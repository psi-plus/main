@echo off
@echo Cloning Cleaner Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/cleanerplugin psi\src\plugins\generic\cleanerplugin
@echo Completed
@echo Building Cleaner Plugin
cd psi\src\plugins\generic\cleanerplugin
call qmake cleanerplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Cleaner Plugin
copy release\cleanerplugin.dll "%PSIPLUSDIR%\plugins\cleanerplugin.dll" /Y
pause
@echo Archiving Cleaner Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-cleanerplugin-0.2.10-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\cleanerplugin.dll"
@echo Completed
@echo Uploading archived Cleaner Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Cleaner Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-cleanerplugin-0.2.10-win32.zip"
@echo Completed
pause & pause
