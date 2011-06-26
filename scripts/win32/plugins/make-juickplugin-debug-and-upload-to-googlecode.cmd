@echo off
@echo Cloning Juick Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/juickplugin psi\src\plugins\generic\juickplugin
@echo Completed
@echo Building Juick Plugin (debug version)
cd psi\src\plugins\generic\juickplugin
call qmake juickplugin.pro
call mingw32-make -f makefile.debug
@echo Completed
pause
@echo Copying Juick Plugin (debug version) to work dir
copy debug\juickplugin.dll "%PSIPLUSDIR%\plugins\juickplugin.dll" /Y
pause
@echo Archiving Juick Plugin (debug version)
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-juickplugin-0.9.17-debug-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\juickplugin.dll"
@echo Completed
@echo Uploading archived Juick Plugin (debug version) to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Juick Plugin for Psi+ || Qt 4.7.0 || FOR DEBUG ONLY!!!" -l "Debug,Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-juickplugin-0.9.17-debug-win32.zip"
@echo Completed
pause & pause
