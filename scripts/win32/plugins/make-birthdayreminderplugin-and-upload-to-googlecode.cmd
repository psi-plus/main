@echo off
@echo Cloning Birthday Reminder Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/birthdayreminderplugin psi\src\plugins\generic\birthdayreminderplugin
call svn export --force http://psi-dev.googlecode.com/svn/trunk/sound psi\src\plugins\generic\birthdayreminderplugin\sound
@echo Completed
@echo Building Birthday Reminder Plugin
cd psi\src\plugins\generic\birthdayreminderplugin
call qmake birthdayreminderplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Birthday Reminder Plugin
copy release\birthdayreminderplugin.dll "%PSIPLUSDIR%\plugins\birthdayreminderplugin.dll" /Y
pause
@echo Archiving Birthday Reminder Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-birthdayreminderplugin-0.3.3-win32.zip" changelog.txt sound\reminder.wav "%PSIPLUSDIR%\plugins\birthdayreminderplugin.dll"
@echo Completed
@echo Uploading archived Birthday Reminder Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Birthday Reminder Plugin for Psi+ || Qt 4.7.1 || changelog and sound included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-birthdayreminderplugin-0.3.3-win32.zip"
@echo Completed
pause & pause
