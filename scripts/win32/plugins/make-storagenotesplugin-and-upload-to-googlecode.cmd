@echo off
@echo Cloning Storage Notes Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/storagenotesplugin psi\src\plugins\generic\storagenotesplugin
@echo Completed
@echo Building Storage Notes Plugin
cd psi\src\plugins\generic\storagenotesplugin
call qmake storagenotesplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Storage Notes Plugin to work dir
copy release\storagenotesplugin.dll "%PSIPLUSDIR%\plugins\storagenotesplugin.dll" /Y
pause
@echo Archiving Storage Notes Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-storagenotesplugin-0.1.4-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\storagenotesplugin.dll"
@echo Completed
@echo Uploading archived Storage Notes Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Storage Notes Plugin for Psi+ || Qt 4.7.0 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-storagenotesplugin-0.1.4-win32.zip"
@echo Completed
pause & pause
