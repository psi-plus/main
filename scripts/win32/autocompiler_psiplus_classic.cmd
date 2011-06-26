@ECHO OFF

:check_compiling
IF EXIST revision_new ECHO Likely last compilation process is not yet completed & EXIT
GOTO :check_psi_sources

:check_psi_sources
ECHO ======================== >> logs
ECHO %DATE% %TIME% >> logs
ECHO :check_psi_sources >> logs
IF NOT EXIST psi ECHO Sources of Psi not found, attempt to create & GOTO :cloning_psi
IF EXIST 9999-psiplus-application-info.diff MOVE /Y 9999-psiplus-application-info.diff patches\9999-psiplus-application-info.diff
ECHO Psi sources found & GOTO :check_psiplus_sources

:cloning_psi
ECHO :cloning_psi >> logs
ECHO Cloning Psi from official repository
"%GITDIR%/bin/git" clone git://github.com/psi-im/psi.git
IF ERRORLEVEL 1 ECHO Unable to clone & RMDIR psi /S /Q & GOTO :exit
ECHO Completed
ECHO Register submodules
CD psi
"%GITDIR%\bin\git" submodule init
ECHO Completed
ECHO Cloning submodules from official repository
"%GITDIR%\bin\git" submodule update
IF ERRORLEVEL 1 ECHO Unable to submodule update & CD .. & RMDIR psi /S /Q & GOTO :exit
ECHO Completed
CD ..
GOTO :check_psiplus_sources

:check_psiplus_sources
ECHO :check_psiplus_sources >> logs
IF NOT EXIST patches ECHO Sources of Psi+ not found, attempt to create & GOTO :cloning_psiplus
ECHO Psi+ sources found & GOTO :check_new_version

:cloning_psiplus
ECHO :cloning_psiplus >> logs
ECHO Creating Psi+ Project
svn checkout http://psi-dev.googlecode.com/svn/trunk/patches
IF ERRORLEVEL 1 ECHO Unable to clone & RMDIR patches /S /Q & GOTO :exit
ECHO Completed
GOTO :check_new_version

:check_new_version
ECHO :check_new_version >> logs
ECHO Checking for new version
svn info http://psi-dev.googlecode.com/svn/trunk/patches | grep 'Rev:' > revision_new
IF ERRORLEVEL 1 ECHO Unable to check & DEL revision_new & GOTO :exit
ECHO N | COMP revision_old revision_new
IF ERRORLEVEL 2 ECHO No. & GOTO :updating_sources
IF ERRORLEVEL 1 ECHO No. & ECHO New version detected, attempt to compile & GOTO :updating_sources
IF ERRORLEVEL 0 ECHO No. & ECHO Newest version is not detected & DEL revision_new & GOTO :exit

:updating_sources
ECHO :updating_sources >> logs
ECHO Updating Psi and Submodules
CD psi
"%GITDIR%\bin\git" pull
IF ERRORLEVEL 1 ECHO Unable to update & CD .. & DEL revision_new & GOTO :exit
"%GITDIR%\bin\git" submodule update
IF ERRORLEVEL 1 ECHO Unable to update & CD .. & DEL revision_new & GOTO :exit
CD ..
ECHO Updating completed
ECHO Updating Psi+ Project
svn cleanup patches
svn up patches
IF ERRORLEVEL 1 ECHO Unable to update & DEL revision_new & GOTO :exit
ECHO Updating completed
GOTO :patching_psi_to_psiplus

:patching_psi_to_psiplus
ECHO :patching_psi_to_psiplus >> logs
ECHO Updating Psi to Psi+
svn export http://psi-dev.googlecode.com/svn/trunk/iconsets/system/default psi/iconsets/system/default --force
IF ERRORLEVEL 1 ECHO Unable to update & GOTO :exit
svn export http://psi-dev.googlecode.com/svn/trunk/iconsets/roster/default psi/iconsets/roster/default --force
IF ERRORLEVEL 1 ECHO Unable to update & GOTO :exit
COPY patches\app.ico psi\win32\app.ico /Y
ECHO Set current time
ECHO SET currentTime=>currentTime
TIME /T>>currentTime
tr -d \n\r<currentTime>currentTime.cmd
CALL currentTime.cmd & DEL currentTime & DEL currentTime.cmd
ECHO Set revision of Psi+
ECHO SET revision=>setrevision
svnversion patches>>setrevision
tr -d \n\r<setrevision>setrevision.cmd
CALL setrevision.cmd & DEL setrevision & DEL setrevision.cmd
MOVE /Y patches\9999-psiplus-application-info.diff 9999-psiplus-application-info.diff
sed "s/\(xxx\)/%revision%/" "9999-psiplus-application-info.diff">patches\9999-psiplus-application-info.diff
CD psi
SET patchdir=..\patches\
DIR /B %patchdir%*.diff | SORT > series.txt
FOR /F %%v IN (series.txt) DO patch -p1 -r rejects -Z<%patchdir%%%v
DEL series.txt
CD ..
ECHO Completed
GOTO :check_rejects

:check_rejects
ECHO :check_rejects >> logs
IF NOT EXIST psi\rejects GOTO :check_configure
GOTO :rejects

:rejects
ECHO :rejects >> logs
RMDIR psi /S /Q
MOVE /Y 9999-psiplus-application-info.diff patches\9999-psiplus-application-info.diff
GOTO :exit

:check_configure
ECHO :check_configure >> logs
IF NOT EXIST psi\conf.pri GOTO :configuring
GOTO :compiling

:configuring
ECHO :configuring >> logs
ECHO Configuring
CD psi
REN iris\conf_win.pri.example conf_win.pri
qconf
IF ERRORLEVEL 1 ECHO Unable to configure & GOTO :reversing_to_psi
configure --enable-plugins --with-openssl-inc=%OPENSSLDir%\outinc --with-openssl-lib=%OPENSSLDir%\lib\MinGW --disable-xss --disable-qdbus --with-aspell-inc=%QTDIR%\..\mingw\include --with-aspell-lib=%QTDIR%\..\mingw\lib
IF ERRORLEVEL 1 ECHO Unable to configure & GOTO :reversing_to_psi
CD ..
GOTO :compiling

:compiling
ECHO :compiling .%revision%>> logs
ECHO :compiling started: %TIME% >> logs
CD psi
ccache mingw32-make
CD ..
IF NOT EXIST psi\src\release\psi-plus.exe ECHO :compiling failed: %TIME% >> logs & ECHO psi-plus.exe not compiled, but maybe will be obtained after next updating & GOTO :reversing_to_psi
ECHO :compiling completed: %TIME% >> logs
GOTO :preparing_for_upload

:preparing_for_upload
ECHO :preparing_for_upload >> logs
MOVE /Y psi\src\release\psi-plus.exe psi-plus.exe
ECHO MOVE /Y psi-plus.exe psi-plus-portable.exe ^&^& DEL make-psi-plus-portable.bat>make-psi-plus-portable.bat
ECHO Archiving build
CALL 7z a -tzip -scsDOS -mx9 "psi-plus-0.15.%revision%-win32.zip" "make-psi-plus-portable.bat" "psi-plus.exe"
IF ERRORLEVEL 1 ECHO Unable add to archive & GOTO :reversing_to_psi
ECHO Completed
GOTO :uploading

:uploading
ECHO :uploading >> logs
ECHO Uploading archived build to Google Code
CALL googlecode_upload.py --user your_google_login --password your_googlecode_password --project psi-dev --summary "Psi+ Nightly Build (Beta) || psi-git %date% %currentTime% MSD || Qt 4.7.1 || Win32 OpenSSL Libs v0.9.8q" --labels "NightlyBuild,Windows,Archive" "psi-plus-0.15.%revision%-win32.zip"
ECHO Completed
GOTO :cleaning

:cleaning
ECHO :cleaning >> logs
DEL psi-plus.exe
DEL make-psi-plus-portable.bat
GOTO :reversing_to_psi

:reversing_to_psi
ECHO :reversing_to_psi >> logs
ECHO Revert Psi+ to Psi
CD psi
SET patchdir=..\patches\
DIR /B %patchdir%*.diff | SORT /R>series.txt
FOR /F %%v IN (series.txt) DO patch -R -p1 -Z< %patchdir%%%v
DEL series.txt
CD ..
MOVE /Y 9999-psiplus-application-info.diff patches\9999-psiplus-application-info.diff
MOVE /Y revision_new revision_old
GOTO :check_psi_sources

:exit
ECHO :exit >> logs
IF EXIST 9999-psiplus-application-info.diff MOVE /Y 9999-psiplus-application-info.diff patches\9999-psiplus-application-info.diff
IF EXIST revision_new MOVE /Y revision_new revision_old
ECHO Script completed
EXIT