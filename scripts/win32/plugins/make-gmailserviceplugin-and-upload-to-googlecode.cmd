@echo off
@echo Cloning Gmail Service Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/gmailserviceplugin psi\src\plugins\generic\gmailserviceplugin
call svn export --force http://psi-dev.googlecode.com/svn/trunk/sound psi\src\plugins\generic\gmailserviceplugin\sound
@echo Completed
@echo Building Gmail Service Plugin
cd psi\src\plugins\generic\gmailserviceplugin
call qmake gmailserviceplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Gmail Service Plugin
copy release\gmailserviceplugin.dll "%PSIPLUSDIR%\plugins\gmailserviceplugin.dll" /Y
pause
@echo Archiving Gmail Service Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-gmailserviceplugin-0.6.6-win32.zip" changelog.txt sound\email.wav "%PSIPLUSDIR%\plugins\gmailserviceplugin.dll"
@echo Completed
@echo Uploading archived Gmail Service Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Gmail Service Plugin for Psi+ || Qt 4.7.1 || changelog and sound included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-gmailserviceplugin-0.6.6-win32.zip"
@echo Completed
pause & pause
