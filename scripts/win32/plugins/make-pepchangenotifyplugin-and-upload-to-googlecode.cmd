@echo off
@echo Cloning PEP Change Notify Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/pepchangenotifyplugin psi\src\plugins\generic\pepchangenotifyplugin
call svn export --force http://psi-dev.googlecode.com/svn/trunk/sound psi\src\plugins\generic\pepchangenotifyplugin\sound
@echo Completed
@echo Building PEP Change Notify Plugin
cd psi\src\plugins\generic\pepchangenotifyplugin
call qmake pepchangenotifyplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying PEP Change Notify Plugin
copy release\pepchangenotifyplugin.dll "%PSIPLUSDIR%\plugins\pepchangenotifyplugin.dll" /Y
pause
@echo Archiving PEP Change Notify Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-pepchangenotifyplugin-0.0.7-win32.zip" changelog.txt sound\pepnotify.wav "%PSIPLUSDIR%\plugins\pepchangenotifyplugin.dll"
@echo Completed
@echo Uploading archived PEP Change Notify Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "PEP Change Notify Plugin for Psi+ || Qt 4.7.1 || changelog and pepnotify.wav included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-pepchangenotifyplugin-0.0.7-win32.zip"
@echo Completed
pause & pause
