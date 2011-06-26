@echo off
@echo Cloning Qip X-statuses Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/qipxstatusesplugin psi\src\plugins\generic\qipxstatusesplugin
@echo Completed
@echo Building Qip X-statuses Plugin
cd psi\src\plugins\generic\qipxstatusesplugin
call qmake qipxstatusesplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Qip X-statuses Plugin to work dir
copy release\qipxstatusesplugin.dll "%PSIPLUSDIR%\plugins\qipxstatusesplugin.dll" /Y
pause
@echo Archiving Qip X-statuses Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-qipxstatusesplugin-0.0.7-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\qipxstatusesplugin.dll"
@echo Completed
@echo Uploading archived Qip X-statuses Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Qip X-statuses Plugin for Psi+ || Qt 4.7.0 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-qipxstatusesplugin-0.0.7-win32.zip"
@echo Completed
pause & pause
