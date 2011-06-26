@echo off
@echo Cloning QConf sources from svn.delta.affinix.com repository
call svn export --force http://delta.affinix.com/svn/trunk/qconf qconf
@echo Completed
@echo Building QConf
cd qconf
call qmake qconf.pro
call mingw32-make -f makefile.release
@echo Completed
@echo Copying QConf files to work dir
mkdir "%QTCONFDIR%"
mkdir "%QTCONFDIR%\conf"
copy conf\conf4.cpp "%QTCONFDIR%\conf" /Y
copy conf\conf4.h "%QTCONFDIR%\conf" /Y
copy conf\conf4.pro "%QTCONFDIR%\conf" /Y
copy conf\conf.cpp "%QTCONFDIR%\conf" /Y
copy conf\conf.pro "%QTCONFDIR%\conf" /Y
mkdir "%QTCONFDIR%\modules"
copy modules\qt31.qcm "%QTCONFDIR%\modules" /Y
copy modules\qt41.qcm "%QTCONFDIR%\modules" /Y
copy qconf.exe "%QTCONFDIR%" /Y
@echo Archiving QConf files
call 7z a -tzip -scsDOS -mx9 ..\qconf1.5-qt4.7.2-win32.zip conf\conf4.cpp conf\conf4.h conf\conf4.pro conf\conf.cpp conf\conf.pro modules\qt31.qcm modules\qt41.qcm qconf.exe
@echo Completed
@echo Uploading archived QConf files to Google Code
call ..\..\..\build\googlecode_upload.py -p "psi-dev" -s "QConf || v1.5 || Qt 4.7.2 || Based on sources from http://delta.affinix.com/qconf" -l "QConf,Windows,Archive" qconf1.5-qt4.7.2-win32.zip
@echo Completed
pause & pause
