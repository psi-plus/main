@echo off
@echo Cloning Juick Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/juickplugin psi\src\plugins\generic\juickplugin
@echo Completed
@echo Building Juick Plugin
cd psi\src\plugins\generic\juickplugin
call qmake juickplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Juick Plugin to work dir
copy release\juickplugin.dll "%PSIPLUSDIR%\plugins\juickplugin.dll" /Y
pause
@echo Archiving Juick Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-juickplugin-0.10.5-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\juickplugin.dll"
@echo Completed
@echo Uploading archived Juick Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Juick Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-juickplugin-0.10.5-win32.zip"
@echo Completed
pause & pause
