@echo off
@echo Cloning Screenshot Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/screenshotplugin psi\src\plugins\generic\screenshotplugin
@echo Completed
@echo Building Screenshot Plugin
cd psi\src\plugins\generic\screenshotplugin
call qmake screenshotplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Archiving Screenshot Plugin to Psi+ plugins dir
copy release\screenshotplugin.dll "%PSIPLUSDIR%\plugins\screenshotplugin.dll" /Y
pause
@echo Archiving Screenshot Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-screenshotplugin-0.4.4-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\screenshotplugin.dll"
@echo Completed
@echo Uploading archived Screenshot Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Screenshot Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-screenshotplugin-0.4.4-win32.zip"
@echo Completed
pause & pause
