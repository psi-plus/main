@echo off
@echo Cloning Watcher Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/watcherplugin psi\src\plugins\generic\watcherplugin
call svn export --force http://psi-dev.googlecode.com/svn/trunk/sound psi\src\plugins\generic\watcherplugin\sound
@echo Completed
@echo Building Watcher Plugin
cd psi\src\plugins\generic\watcherplugin
call qmake watcherplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Watcher Plugin to Psi+ plugins dir
copy release\watcherplugin.dll "%PSIPLUSDIR%\plugins\watcherplugin.dll" /Y
pause
@echo Archiving Watcher Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-watcherplugin-0.3.9-win32.zip" changelog.txt sound\watcher.wav "%PSIPLUSDIR%\plugins\watcherplugin.dll"
@echo Completed
@echo Uploading archived Watcher Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Watcher Plugin for Psi+ || Qt 4.7.1 || changelog and sound included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-watcherplugin-0.3.9-win32.zip"
@echo Completed
pause & pause
