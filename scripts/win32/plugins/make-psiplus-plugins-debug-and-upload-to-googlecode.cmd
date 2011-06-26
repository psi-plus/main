@echo off
@echo Cloning Psi+ Plugins sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic psi\src\plugins\generic
pause
@echo Completed
@echo Building Psi+ Plugins (Debug)
cd psi\src\plugins\generic\attentionplugin
call qmake attentionplugin.pro
call mingw32-make -f makefile.debug
cd ..\autoreplyplugin
call qmake autoreplyplugin.pro
call mingw32-make -f makefile.debug
cd ..\birthdayreminderplugin
call qmake birthdayreminderplugin.pro
call mingw32-make -f makefile.debug
cd ..\captchaformsplugin
call qmake captchaformsplugin.pro
call mingw32-make -f makefile.debug
cd ..\chessplugin
call qmake chessplugin.pro
call mingw32-make -f makefile.debug
cd ..\cleanerplugin
call qmake cleanerplugin.pro
call mingw32-make -f makefile.debug
cd ..\clientswitcherplugin
call qmake clientswitcherplugin.pro
call mingw32-make -f makefile.debug
cd ..\conferenceloggerplugin
call qmake conferenceloggerplugin.pro
call mingw32-make -f makefile.debug
cd ..\contentdownloaderplugin
call qmake contentdownloaderplugin.pro
call mingw32-make -f makefile.debug
cd ..\extendedmenuplugin
call qmake extendedmenuplugin.pro
call mingw32-make -f makefile.debug
cd ..\extendedoptionsplugin
call qmake extendedoptionsplugin.pro
call mingw32-make -f makefile.debug
cd ..\gmailserviceplugin
call qmake gmailserviceplugin.pro
call mingw32-make -f makefile.debug
cd ..\gomokugameplugin
call qmake gomokugameplugin.pro
call mingw32-make -f makefile.debug
cd ..\historykeeperplugin
call qmake historykeeperplugin.pro
call mingw32-make -f makefile.debug
cd ..\icqdieplugin
call qmake icqdieplugin.pro
call mingw32-make -f makefile.debug
cd ..\imageplugin
call qmake imageplugin.pro
call mingw32-make -f makefile.debug
cd ..\jabberdiskplugin
call qmake jabberdiskplugin.pro
call mingw32-make -f makefile.debug
cd ..\juickplugin
call qmake juickplugin.pro
call mingw32-make -f makefile.debug
cd ..\pepchangenotifyplugin
call qmake pepchangenotifyplugin.pro
call mingw32-make -f makefile.debug
cd ..\qipxstatusesplugin
call qmake qipxstatusesplugin.pro
call mingw32-make -f makefile.debug
cd ..\screenshotplugin
call qmake screenshotplugin.pro
call mingw32-make -f makefile.debug
cd ..\skinsplugin
call qmake skinsplugin.pro
call mingw32-make -f makefile.debug
cd ..\stopspamplugin
call qmake stopspamplugin.pro
call mingw32-make -f makefile.debug
cd ..\storagenotesplugin
call qmake storagenotesplugin.pro
call mingw32-make -f makefile.debug
cd ..\translateplugin
call qmake translateplugin.pro
call mingw32-make -f makefile.debug
cd ..\watcherplugin
call qmake watcherplugin.pro
call mingw32-make -f makefile.debug
cd ..
@echo Completed
pause
@echo Copying Psi+ Plugins (Debug) to work dir
copy attentionplugin\debug\attentionplugin.dll "%PSIPLUSDIR%\plugins\attentionplugin.dll" /Y
copy autoreplyplugin\debug\autoreplyplugin.dll "%PSIPLUSDIR%\plugins\autoreplyplugin.dll" /Y
copy birthdayreminderplugin\debug\birthdayreminderplugin.dll "%PSIPLUSDIR%\plugins\birthdayreminderplugin.dll" /Y
copy captchaformsplugin\debug\captchaformsplugin.dll "%PSIPLUSDIR%\plugins\captchaformsplugin.dll" /Y
copy chessplugin\debug\chessplugin.dll "%PSIPLUSDIR%\plugins\chessplugin.dll" /Y
copy cleanerplugin\debug\cleanerplugin.dll "%PSIPLUSDIR%\plugins\cleanerplugin.dll" /Y
copy clientswitcherplugin\debug\clientswitcherplugin.dll "%PSIPLUSDIR%\plugins\clientswitcherplugin.dll" /Y
copy conferenceloggerplugin\debug\conferenceloggerplugin.dll "%PSIPLUSDIR%\plugins\conferenceloggerplugin.dll" /Y
copy contentdownloaderplugin\debug\contentdownloaderplugin.dll "%PSIPLUSDIR%\plugins\contentdownloaderplugin.dll" /Y
copy extendedmenuplugin\debug\extendedmenuplugin.dll "%PSIPLUSDIR%\plugins\extendedmenuplugin.dll" /Y
copy extendedoptionsplugin\debug\extendedoptionsplugin.dll "%PSIPLUSDIR%\plugins\extendedoptionsplugin.dll" /Y
copy gmailserviceplugin\debug\gmailserviceplugin.dll "%PSIPLUSDIR%\plugins\gmailserviceplugin.dll" /Y
copy gomokugameplugin\debug\gomokugameplugin.dll "%PSIPLUSDIR%\plugins\gomokugameplugin.dll" /Y
copy historykeeperplugin\debug\historykeeperplugin.dll "%PSIPLUSDIR%\plugins\historykeeperplugin.dll" /Y
copy icqdieplugin\debug\icqdieplugin.dll "%PSIPLUSDIR%\plugins\icqdieplugin.dll" /Y
copy imageplugin\debug\imageplugin.dll "%PSIPLUSDIR%\plugins\imageplugin.dll" /Y
copy jabberdiskplugin\debug\jabberdiskplugin.dll "%PSIPLUSDIR%\plugins\jabberdiskplugin.dll" /Y
copy juickplugin\debug\juickplugin.dll "%PSIPLUSDIR%\plugins\juickplugin.dll" /Y
copy pepchangenotifyplugin\debug\pepchangenotifyplugin.dll "%PSIPLUSDIR%\plugins\pepchangenotifyplugin.dll" /Y
copy qipxstatusesplugin\debug\qipxstatusesplugin.dll "%PSIPLUSDIR%\plugins\qipxstatusesplugin.dll" /Y
copy screenshotplugin\debug\screenshotplugin.dll "%PSIPLUSDIR%\plugins\screenshotplugin.dll" /Y
copy skinsplugin\debug\skinsplugin.dll "%PSIPLUSDIR%\plugins\skinsplugin.dll" /Y
copy stopspamplugin\debug\stopspamplugin.dll "%PSIPLUSDIR%\plugins\stopspamplugin.dll" /Y
copy storagenotesplugin\debug\storagenotesplugin.dll "%PSIPLUSDIR%\plugins\storagenotesplugin.dll" /Y
copy translateplugin\debug\translateplugin.dll "%PSIPLUSDIR%\plugins\translateplugin.dll" /Y
copy watcherplugin\debug\watcherplugin.dll "%PSIPLUSDIR%\plugins\watcherplugin.dll" /Y
@echo Archiving Psi+ Plugins (Debug)
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-plugins-0.15.3482-debug-win32.zip" "%PSIPLUSDIR%\plugins\*.dll"
@echo Completed
@echo Uploading archived Psi+ Plugins to Google Code
call ..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Psi+ Plugins || Debug || Qt 4.7.1 || FOR DEBUG ONLY!!!" -l "Debug,Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-plugins-0.15.3482-debug-win32.zip"
@echo Completed
pause & pause
