@echo off
@echo Cloning Stop Spam Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/stopspamplugin psi\src\plugins\generic\stopspamplugin
@echo Completed
@echo Building Stop Spam Plugin
cd psi\src\plugins\generic\stopspamplugin
call qmake stopspamplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Stop Spam Plugin to work dir
copy release\stopspamplugin.dll "%PSIPLUSDIR%\plugins\stopspamplugin.dll" /Y
pause
@echo Archiving Stop Spam Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-stopspamplugin-0.5.2-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\stopspamplugin.dll"
@echo Completed
@echo Uploading archived Stop Spam Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Stop Spam Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-stopspamplugin-0.5.2-win32.zip"
@echo Completed
pause & pause
