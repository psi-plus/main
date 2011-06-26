@echo off
@echo Cloning Content Downloader Plugin sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic/contentdownloaderplugin psi\src\plugins\generic\contentdownloaderplugin
@echo Completed
@echo Building Content Downloader Plugin
cd psi\src\plugins\generic\contentdownloaderplugin
call qmake contentdownloaderplugin.pro
call mingw32-make -f makefile.release
@echo Completed
pause
@echo Copying Content Downloader Plugin to work dir
copy release\contentdownloaderplugin.dll "%PSIPLUSDIR%\plugins\contentdownloaderplugin.dll" /Y
pause
@echo Archiving Content Downloader Plugin
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-contentdownloaderplugin-0.1.10-win32.zip" changelog.txt "%PSIPLUSDIR%\plugins\contentdownloaderplugin.dll"
@echo Completed
@echo Uploading archived Content Downloader Plugin to Google Code
call ..\..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Content Downloader Plugin for Psi+ || Qt 4.7.1 || changelog included" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-contentdownloaderplugin-0.1.10-win32.zip"
@echo Completed
pause & pause
