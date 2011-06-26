@echo off
@echo Cloning Client Switcher Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/clientswitcherplugin psi\src\plugins\generic\clientswitcherplugin
@echo Completed
@echo Building Client Switcher Plugin
cd psi\src\plugins\generic\clientswitcherplugin
call qmake clientswitcherplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Client Switcher Plugin
copy release\clientswitcherplugin.dll "%PSIPLUSDIR%\plugins\clientswitcherplugin.dll" /Y
pause
@echo Archiving Client Switcher Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-clientswitcherplugin-0.0.6-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\clientswitcherplugin.dll"
@echo Completed
@echo Uploading archived Client Switcher Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Client Switcher Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-clientswitcherplugin-0.0.6-win32.zip"
@echo Completed
pause & pause
