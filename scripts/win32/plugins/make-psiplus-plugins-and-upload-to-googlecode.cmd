@echo off
@echo Cloning Psi+ Plugins sources from Psi+ repository
call svn export --force http://psi-dev.googlecode.com/svn/trunk/plugins/generic psi\src\plugins\generic
pause
@echo Completed
@echo Building Psi+ Plugins
cd psi\src\plugins\generic\attentionplugin
call qmake attentionplugin.pro
call mingw32-make -f makefile.release
cd ..\autoreplyplugin
call qmake autoreplyplugin.pro
call mingw32-make -f makefile.release
cd ..\birthdayreminderplugin
call qmake birthdayreminderplugin.pro
call mingw32-make -f makefile.release
cd ..\captchaformsplugin
call qmake captchaformsplugin.pro
call mingw32-make -f makefile.release
cd ..\chessplugin
call qmake chessplugin.pro
call mingw32-make -f makefile.release
cd ..\cleanerplugin
call qmake cleanerplugin.pro
call mingw32-make -f makefile.release
cd ..\clientswitcherplugin
call qmake clientswitcherplugin.pro
call mingw32-make -f makefile.release
cd ..\conferenceloggerplugin
call qmake conferenceloggerplugin.pro
call mingw32-make -f makefile.release
cd ..\contentdownloaderplugin
call qmake contentdownloaderplugin.pro
call mingw32-make -f makefile.release
cd ..\extendedmenuplugin
call qmake extendedmenuplugin.pro
call mingw32-make -f makefile.release
cd ..\extendedoptionsplugin
call qmake extendedoptionsplugin.pro
call mingw32-make -f makefile.release
cd ..\gmailserviceplugin
call qmake gmailserviceplugin.pro
call mingw32-make -f makefile.release
cd ..\gomokugameplugin
call qmake gomokugameplugin.pro
call mingw32-make -f makefile.release
cd ..\historykeeperplugin
call qmake historykeeperplugin.pro
call mingw32-make -f makefile.release
cd ..\icqdieplugin
call qmake icqdieplugin.pro
call mingw32-make -f makefile.release
cd ..\imageplugin
call qmake imageplugin.pro
call mingw32-make -f makefile.release
cd ..\jabberdiskplugin
call qmake jabberdiskplugin.pro
call mingw32-make -f makefile.release
cd ..\juickplugin
call qmake juickplugin.pro
call mingw32-make -f makefile.release
cd ..\pepchangenotifyplugin
call qmake pepchangenotifyplugin.pro
call mingw32-make -f makefile.release
cd ..\qipxstatusesplugin
call qmake qipxstatusesplugin.pro
call mingw32-make -f makefile.release
cd ..\screenshotplugin
call qmake screenshotplugin.pro
call mingw32-make -f makefile.release
cd ..\skinsplugin
call qmake skinsplugin.pro
call mingw32-make -f makefile.release
cd ..\stopspamplugin
call qmake stopspamplugin.pro
call mingw32-make -f makefile.release
cd ..\storagenotesplugin
call qmake storagenotesplugin.pro
call mingw32-make -f makefile.release
cd ..\translateplugin
call qmake translateplugin.pro
call mingw32-make -f makefile.release
cd ..\watcherplugin
call qmake watcherplugin.pro
call mingw32-make -f makefile.release
cd ..
@echo Completed
pause
@echo Copying Psi+ Plugins to work dir
mkdir "%PSIPLUSDIR%\plugins\changelogs"
copy attentionplugin\release\attentionplugin.dll "%PSIPLUSDIR%\plugins\attentionplugin.dll" /Y
copy attentionplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\attentionplugin.txt" /Y
copy autoreplyplugin\release\autoreplyplugin.dll "%PSIPLUSDIR%\plugins\autoreplyplugin.dll" /Y
copy autoreplyplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\autoreplyplugin.txt" /Y
copy birthdayreminderplugin\release\birthdayreminderplugin.dll "%PSIPLUSDIR%\plugins\birthdayreminderplugin.dll" /Y
copy birthdayreminderplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\birthdayreminderplugin.txt" /Y
copy captchaformsplugin\release\captchaformsplugin.dll "%PSIPLUSDIR%\plugins\captchaformsplugin.dll" /Y
copy captchaformsplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\captchaformsplugin.txt" /Y
copy chessplugin\release\chessplugin.dll "%PSIPLUSDIR%\plugins\chessplugin.dll" /Y
copy chessplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\chessplugin.txt" /Y
copy cleanerplugin\release\cleanerplugin.dll "%PSIPLUSDIR%\plugins\cleanerplugin.dll" /Y
copy cleanerplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\cleanerplugin.txt" /Y
copy clientswitcherplugin\release\clientswitcherplugin.dll "%PSIPLUSDIR%\plugins\clientswitcherplugin.dll" /Y
copy clientswitcherplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\clientswitcherplugin.txt" /Y
copy conferenceloggerplugin\release\conferenceloggerplugin.dll "%PSIPLUSDIR%\plugins\conferenceloggerplugin.dll" /Y
copy conferenceloggerplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\conferenceloggerplugin.txt" /Y
copy contentdownloaderplugin\release\contentdownloaderplugin.dll "%PSIPLUSDIR%\plugins\contentdownloaderplugin.dll" /Y
copy contentdownloaderplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\contentdownloaderplugin.txt" /Y
copy extendedmenuplugin\release\extendedmenuplugin.dll "%PSIPLUSDIR%\plugins\extendedmenuplugin.dll" /Y
copy extendedmenuplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\extendedmenuplugin.txt" /Y
copy extendedoptionsplugin\release\extendedoptionsplugin.dll "%PSIPLUSDIR%\plugins\extendedoptionsplugin.dll" /Y
copy extendedoptionsplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\extendedoptionsplugin.txt" /Y
copy gmailserviceplugin\release\gmailserviceplugin.dll "%PSIPLUSDIR%\plugins\gmailserviceplugin.dll" /Y
copy gmailserviceplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\gmailserviceplugin.txt" /Y
copy gomokugameplugin\release\gomokugameplugin.dll "%PSIPLUSDIR%\plugins\gomokugameplugin.dll" /Y
copy gomokugameplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\gomokugameplugin.txt" /Y
copy historykeeperplugin\release\historykeeperplugin.dll "%PSIPLUSDIR%\plugins\historykeeperplugin.dll" /Y
copy historykeeperplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\historykeeperplugin.txt" /Y
copy icqdieplugin\release\icqdieplugin.dll "%PSIPLUSDIR%\plugins\icqdieplugin.dll" /Y
copy icqdieplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\icqdieplugin.txt" /Y
copy imageplugin\release\imageplugin.dll "%PSIPLUSDIR%\plugins\imageplugin.dll" /Y
copy imageplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\imageplugin.txt" /Y
copy jabberdiskplugin\release\jabberdiskplugin.dll "%PSIPLUSDIR%\plugins\jabberdiskplugin.dll" /Y
copy jabberdiskplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\jabberdiskplugin.txt" /Y
copy juickplugin\release\juickplugin.dll "%PSIPLUSDIR%\plugins\juickplugin.dll" /Y
copy juickplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\juickplugin.txt" /Y
copy pepchangenotifyplugin\release\pepchangenotifyplugin.dll "%PSIPLUSDIR%\plugins\pepchangenotifyplugin.dll" /Y
copy pepchangenotifyplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\pepchangenotifyplugin.txt" /Y
copy qipxstatusesplugin\release\qipxstatusesplugin.dll "%PSIPLUSDIR%\plugins\qipxstatusesplugin.dll" /Y
copy qipxstatusesplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\qipxstatusesplugin.txt" /Y
copy screenshotplugin\release\screenshotplugin.dll "%PSIPLUSDIR%\plugins\screenshotplugin.dll" /Y
copy screenshotplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\screenshotplugin.txt" /Y
copy skinsplugin\release\skinsplugin.dll "%PSIPLUSDIR%\plugins\skinsplugin.dll" /Y
copy skinsplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\skinsplugin.txt" /Y
copy stopspamplugin\release\stopspamplugin.dll "%PSIPLUSDIR%\plugins\stopspamplugin.dll" /Y
copy stopspamplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\stopspamplugin.txt" /Y
copy storagenotesplugin\release\storagenotesplugin.dll "%PSIPLUSDIR%\plugins\storagenotesplugin.dll" /Y
copy storagenotesplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\storagenotesplugin.txt" /Y
copy translateplugin\release\translateplugin.dll "%PSIPLUSDIR%\plugins\translateplugin.dll" /Y
copy translateplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\translateplugin.txt" /Y
copy watcherplugin\release\watcherplugin.dll "%PSIPLUSDIR%\plugins\watcherplugin.dll" /Y
copy watcherplugin\changelog.txt "%PSIPLUSDIR%\plugins\changelogs\watcherplugin.txt" /Y
@echo Archiving Psi+ Plugins
call 7z a -tzip -scsDOS -mx9 "%PSIPLUSDIR%\plugins\psi-plus-plugins-0.15.3753-win32.zip" "%PSIPLUSDIR%\plugins\changelogs" "%PSIPLUSDIR%\plugins\*.dll"
@echo Completed
@echo Uploading archived Psi+ Plugins to Google Code
call ..\..\..\..\googlecode_upload.py -p "psi-dev" -s "Psi+ Plugins || Qt 4.7.2" -l "Plugins,Windows,Archive" "%PSIPLUSDIR%\plugins\psi-plus-plugins-0.15.3753-win32.zip"
@echo Completed
pause & pause
