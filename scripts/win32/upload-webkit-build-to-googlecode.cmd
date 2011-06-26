@echo off
@echo Copying Psi+ Webkit Build to Psi+ directory
move /Y "%PSIPLUSDIR%\psi-plus.exe" "%PSIPLUSDIR%\psi-plus.ex_"
copy psi-plus.exe "%PSIPLUSDIR%\psi-plus.exe" /Y
mkdir "%PSIPLUSDIR%\themes"
mkdir "%PSIPLUSDIR%\themes\chatview"
mkdir "%PSIPLUSDIR%\themes\chatview\adium"
copy psi\themes\chatview\adium\adapter.js "%PSIPLUSDIR%\themes\chatview\adium\adapter.js" /Y
copy psi\themes\chatview\adium\Template.html "%PSIPLUSDIR%\themes\chatview\adium\Template.html" /Y
mkdir "%PSIPLUSDIR%\themes\chatview\psi"
mkdir "%PSIPLUSDIR%\themes\chatview\psi\classic"
copy psi\themes\chatview\psi\classic\index.html "%PSIPLUSDIR%\themes\chatview\psi\classic\index.html" /Y
copy psi\themes\chatview\psi\classic\load.js "%PSIPLUSDIR%\themes\chatview\psi\classic\load.js" /Y
copy psi\themes\chatview\psi\adapter.js "%PSIPLUSDIR%\themes\chatview\psi\adapter.js" /Y
copy psi\themes\chatview\util.js "%PSIPLUSDIR%\themes\chatview\util.js" /Y
@echo Archiving Webkit build
pause
call 7z a -mx9 "%PSIPLUSDIR%\psi-plus-0.15.3957-webkit-win32.7z" "%PSIPLUSDIR%\themes" "%PSIPLUSDIR%\make-psi-plus-portable.bat" "%PSIPLUSDIR%\psi-plus.exe" "%PSIPLUSDIR%\readme.txt"
@echo Completed
@echo Uploading archived Webkit build to Google Code
call googlecode_upload.py -p "psi-dev" -s "Psi+ WebKit Nightly Build || psi-git 2011-05-31 13:04 MSD || Qt 4.7.2 || Win32 OpenSSL Libs v0.9.8r || see the file README.TXT inside the archive" -l "WebKit,Windows,Archive" "%PSIPLUSDIR%\psi-plus-0.15.3957-webkit-win32.7z"
@echo Completed
pause & pause
