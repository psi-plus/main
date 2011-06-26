@echo off
@echo Cloning Jabber Disk Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/jabberdiskplugin psi\src\plugins\generic\jabberdiskplugin
@echo Completed
@echo Building Jabber Disk Plugin
cd psi\src\plugins\generic\jabberdiskplugin
call qmake jabberdiskplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Jabber Disk Plugin to work dir
copy release\jabberdiskplugin.dll "%PSIPLUSDIR%\plugins\jabberdiskplugin.dll" /Y
pause
@echo Archiving Jabber Disk Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-jabberdiskplugin-0.0.3-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\jabberdiskplugin.dll"
@echo Completed
@echo Uploading archived Jabber Disk Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Jabber Disk Plugin for Psi+ || Qt 4.7.2 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-jabberdiskplugin-0.0.3-win32.zip"
@echo Completed
pause & pause
