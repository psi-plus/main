@echo off
@echo Cloning Chess Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/chessplugin psi\src\plugins\generic\chessplugin
call svn export --force http://psi-dev.googlecode.com/svn/trunk/sound psi\src\plugins\generic\chessplugin\sound
@echo Completed
@echo Building Chess Plugin
cd psi\src\plugins\generic\chessplugin
call qmake chessplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Chess Plugin to work dir
copy release\chessplugin.dll "%PSIPLUSDIR%\plugins\chessplugin.dll" /Y
pause
@echo Archiving Chess Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-chessplugin-0.2.4-win32.zip" changelog.txt sound\chess_error.wav sound\chess_finish.wav sound\chess_move.wav sound\chess_start.wav "%PSIPLUSDIR%\plugins\chessplugin.dll"
@echo Completed
@echo Uploading archived Chess Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Chess Plugin for Psi+ || Qt 4.7.1 || changelog and sounds included || tkabber compatible" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-chessplugin-0.2.4-win32.zip"
@echo Completed
pause & pause
