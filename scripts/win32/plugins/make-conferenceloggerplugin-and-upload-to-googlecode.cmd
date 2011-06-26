@echo off
@echo Cloning Conference Logger Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/conferenceloggerplugin psi\src\plugins\generic\conferenceloggerplugin
@echo Completed
@echo Building Conference Logger Plugin
cd psi\src\plugins\generic\conferenceloggerplugin
call qmake conferenceloggerplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Conference Logger Plugin
copy release\conferenceloggerplugin.dll "%PSIPLUSDIR%\plugins\conferenceloggerplugin.dll" /Y
pause
@echo Archiving Conference Logger Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-conferenceloggerplugin-0.1.9-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\conferenceloggerplugin.dll"
@echo Completed
@echo Uploading archived Conference Logger Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Conference Logger Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-conferenceloggerplugin-0.1.9-win32.zip"
@echo Completed
pause & pause
