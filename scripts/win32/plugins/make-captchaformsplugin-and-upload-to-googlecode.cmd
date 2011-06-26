@echo off
@echo Cloning Captcha Forms Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/captchaformsplugin psi\src\plugins\generic\captchaformsplugin
@echo Completed
@echo Building Captcha Forms Plugin
cd psi\src\plugins\generic\captchaformsplugin
call qmake captchaformsplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Captcha Forms Plugin to work dir
copy release\captchaformsplugin.dll "%PSIPLUSDIR%\plugins\captchaformsplugin.dll" /Y
pause
@echo Archiving Captcha Forms Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-captchaformsplugin-0.0.8-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\captchaformsplugin.dll"
@echo Completed
@echo Uploading archived Captcha Forms Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Captcha Forms Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-captchaformsplugin-0.0.8-win32.zip"
@echo Completed
pause & pause
