@echo off
@echo Cloning Image Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/imageplugin psi\src\plugins\generic\imageplugin
@echo Completed
@echo Building Image Plugin
cd psi\src\plugins\generic\imageplugin
call qmake imageplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Image Plugin
copy release\imageplugin.dll "%PSIPLUSDIR%\plugins\imageplugin.dll" /Y
pause
@echo Archiving Image Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-imageplugin-0.1.0-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\imageplugin.dll"
@echo Completed
@echo Uploading archived Image Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Image Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-imageplugin-0.1.0-win32.zip"
@echo Completed
pause & pause
