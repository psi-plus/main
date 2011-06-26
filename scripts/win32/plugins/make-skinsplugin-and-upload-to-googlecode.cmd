@echo off
@echo Cloning Skins Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/skinsplugin psi\src\plugins\generic\skinsplugin
@echo Completed
@echo Building Skins Plugin
cd psi\src\plugins\generic\skinsplugin
call qmake skinsplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Skins Plugin to work dir
copy release\skinsplugin.dll "%PSIPLUSDIR%\plugins\skinsplugin.dll" /Y
pause
@echo Archiving Skins Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-skinsplugin-0.3.0-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\skinsplugin.dll"
@echo Completed
@echo Uploading archived Skins Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Skins Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-skinsplugin-0.3.0-win32.zip"
@echo Completed
pause & pause
