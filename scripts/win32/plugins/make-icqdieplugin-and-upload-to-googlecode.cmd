@echo off
@echo Cloning ICQ Must Die Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/icqdieplugin psi\src\plugins\generic\icqdieplugin
@echo Completed
@echo Building ICQ Must Die Plugin
cd psi\src\plugins\generic\icqdieplugin
call qmake icqdieplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Archiving ICQ Must Die Plugin
copy release\icqdieplugin.dll "%PSIPLUSDIR%\plugins\icqdieplugin.dll" /Y
pause
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-icqdieplugin-0.1.5-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\icqdieplugin.dll"
@echo Completed
@echo Uploading archived ICQ Must Die Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "ICQ Must Die Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-icqdieplugin-0.1.5-win32.zip"
@echo Completed
pause & pause
