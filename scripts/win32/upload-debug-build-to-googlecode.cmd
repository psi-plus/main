@echo off
@echo Copying Psi+ Debug Build to Psi+ directory
move /Y "%PSIPLUSDIR%\psi-plus.exe" "%PSIPLUSDIR%\psi-plus.ex_"
copy psi-plus.exe "%PSIPLUSDIR%\psi-plus.exe" /Y
pause
@echo Archiving Psi+ Debug Build
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\psi-plus-0.15.3489-debug-win32.zip" "%PSIPLUSDIR%\make-psi-portable.bat" "%PSIPLUSDIR%\psi-plus.exe"
@echo Completed
@echo Uploading archived Psi+ Debug Build to Google Code
call googlecode_upload.py -p "psi-dev" -s "Psi+ Debug Build || psi-git 2011-01-13 18:54 MSD || Qt 4.7.1 || FOR DEBUG ONLY!!!" -l "Debug,Windows,Archive" "%PSIPLUSDIR%\psi-plus-0.15.3489-debug-win32.zip"
@echo Completed
pause & pause
