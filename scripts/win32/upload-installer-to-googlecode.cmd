@echo off
@echo Uploading Psi+ Installer to Google Code
call googlecode_upload.py -p "psi-dev" -s "Psi+ Windows Installer || psi-git 2011-06-12 16:48 MSD || Qt 4.7.2 || Win32 OpenSSL Libs v0.9.8r || Psimedia/GStreamer included" -l "Featured,Windows,Installer" "..\setup\psi-plus-0.15.4018-win32-setup.exe"
@echo Completed
pause & pause
