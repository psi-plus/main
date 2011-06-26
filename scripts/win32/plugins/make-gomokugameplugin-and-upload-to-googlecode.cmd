@echo off
@echo Cloning Gomoku Game Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/gomokugameplugin psi\src\plugins\generic\gomokugameplugin
call svn export --force http://psi-dev.googlecode.com/svn/trunk/sound psi\src\plugins\generic\gomokugameplugin\sound
@echo Completed
@echo Building Gomoku Game Plugin
cd psi\src\plugins\generic\gomokugameplugin
call qmake gomokugameplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Gomoku Game Plugin
copy release\gomokugameplugin.dll "%PSIPLUSDIR%\plugins\gomokugameplugin.dll" /Y
pause
@echo Archiving Gomoku Game Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-gomokugameplugin-0.0.4-win32.zip" changelog.txt sound\chess_error.wav sound\chess_finish.wav sound\chess_move.wav sound\chess_start.wav "%PSIPLUSDIR%\plugins\gomokugameplugin.dll"
@echo Completed
@echo Uploading archived Gomoku Game Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Gomoku Game Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-gomokugameplugin-0.0.4-win32.zip"
@echo Completed
pause & pause
