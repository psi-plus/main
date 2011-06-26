@echo off
@echo Cloning Psi+ Russian localization sources from official repository
svn export --force http://psi-ru.googlecode.com/svn/branches/psi-plus/ lang
pause
lrelease lang\psi_ru.ts
lrelease lang\qt\qt_ru.ts
move /Y lang\psi_ru.qm "%PSIPLUSDIR%\psi_ru.qm"
move /Y lang\qt\qt_ru.qm "%PSIPLUSDIR%\qt_ru.qm"
@echo Archiving Psi+ Russian localization binaries
call 7z a -mx9 "%PSIPLUSDIR%\psi-ru-lang-r201.7z" "%PSIPLUSDIR%\psi_ru.qm" "%PSIPLUSDIR%\qt_ru.qm"
@echo Completed
@echo Uploading archived Psi+ Russian localization binaries to Google Code
call googlecode_upload.py -p "psi-dev" -s "Psi+ Russian Localization || Qt 4.7.2" -l "Russian,Localization,Archive" "%PSIPLUSDIR%\psi-ru-lang-r201.7z"
@echo Completed
pause & pause
