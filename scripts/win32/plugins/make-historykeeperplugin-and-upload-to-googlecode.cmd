@echo off
@echo Cloning History Keeper Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/historykeeperplugin psi\src\plugins\generic\historykeeperplugin
@echo Completed
@echo Building History Keeper Plugin
cd psi\src\plugins\generic\historykeeperplugin
call qmake historykeeperplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying History Keeper Plugin
copy release\historykeeperplugin.dll "%PSIPLUSDIR%\plugins\historykeeperplugin.dll" /Y
pause
@echo Archiving History Keeper Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-historykeeperplugin-0.0.5-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\historykeeperplugin.dll"
@echo Completed
@echo Uploading archived History Keeper Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "History Keeper Plugin for Psi+ || Qt 4.7.0 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-historykeeperplugin-0.0.5-win32.zip"
@echo Completed
pause & pause
