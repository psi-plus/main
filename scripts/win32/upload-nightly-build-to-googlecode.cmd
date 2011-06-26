@echo off
@echo Copying Psi+ Nightly Build to Psi+ directory
move /Y "%PSIPLUSDIR%\psi-plus.exe" "%PSIPLUSDIR%\psi-plus.ex_"
copy psi-plus.exe "%PSIPLUSDIR%\psi-plus.exe" /Y
pause
@echo Archiving Psi+ Nightly Build
call 7z a -mx9 "%PSIPLUSDIR%\psi-plus-0.15.4059-win32.7z" "%PSIPLUSDIR%\make-psi-plus-portable.bat" "%PSIPLUSDIR%\psi-plus.exe"
@echo Completed
@echo Uploading archived Psi+ Nightly Build to Google Code
call googlecode_upload.py -p "psi-dev" -s "Psi+ Nightly Build || psi-git 2011-06-18 23:36 MSD || Qt 4.7.2 || Win32 OpenSSL Libs v0.9.8r" -l "NightlyBuild,Windows,Archive" "%PSIPLUSDIR%\psi-plus-0.15.4059-win32.7z"
@echo Completed
pause & pause

