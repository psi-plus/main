@echo off
@echo Cloning Attention Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/attentionplugin psi\src\plugins\generic\attentionplugin
call svn export --force http://psi-dev.googlecode.com/svn/trunk/sound psi\src\plugins\generic\attentionplugin\sound
@echo Completed
@echo Building Attention Plugin
cd psi\src\plugins\generic\attentionplugin
call qmake attentionplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Attention Plugin
copy release\attentionplugin.dll "%PSIPLUSDIR%\plugins\attentionplugin.dll" /Y
pause
@echo Archiving Attention Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-attentionplugin-0.1.6-win32.zip" changelog.txt sound\attention.wav "%PSIPLUSDIR%\plugins\attentionplugin.dll"
@echo Completed
@echo Uploading archived Attention Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Attention Plugin for Psi+ || Qt 4.7.1 || changelog and sound included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-attentionplugin-0.1.6-win32.zip"
@echo Completed
pause & pause
