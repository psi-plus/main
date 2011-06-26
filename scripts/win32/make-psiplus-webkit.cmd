@echo off
@echo Cloning Psi from official repository
"%GITDIR%\bin\git" clone git://git.psi-im.org/psi.git
@echo Completed
@echo Register submodules
cd psi
"%GITDIR%\bin\git" submodule init
@echo Completed
@echo Cloning submodules from official repository
"%GITDIR%\bin\git" submodule update
cd ..
@echo Completed
@echo Creating Psi+ Project
svn checkout http://psi-dev.googlecode.com/svn/trunk/patches
@echo Completed
@echo Updating Psi to Psi+
svn export --force http://psi-dev.googlecode.com/svn/trunk/iconsets/roster/default psi\iconsets\roster\default
svn export --force http://psi-dev.googlecode.com/svn/trunk/iconsets/system/default psi\iconsets\system\default
copy patches\app.ico psi\win32\app.ico /Y
rem pause
@echo set revision=>set
svnversion patches>>revision
copy /B /Y set + revision setrevision
"%GITDIR%\bin\tr" -d \n\r<setrevision>setrevision.cmd
call setrevision.cmd & del set & del revision & del setrevision & del setrevision.cmd
ren patches\9999-psiplus-application-info.diff 9999-psiplus-application-info.diff.backup
"%GITDIR%\bin\sed" "s/\(xxx\)/%revision%/" "patches\9999-psiplus-application-info.diff.backup">patches\9999-psiplus-application-info.diff
cd psi
set patchdir=..\patches\
set patchlist=series.txt
dir /B %patchdir%*.diff |sort>%patchlist%
for /F "delims=" %%v in (%patchlist%) do @"%GITDIR%\bin\patch" -r rejected_%%v.txt -p1<%patchdir%%%v
del series.txt
@for /F "delims=" %%a in ('dir ^| find "rejected_" /C') do @set count=%%a
@if not %count%==0 goto rejected
cd ..
move /Y patches\9999-psiplus-application-info.diff.backup patches\9999-psiplus-application-info.diff
ren psi\iris\conf_win.pri.example conf_win.pri
@echo Completed
@echo Configuring Psi+ Build
cd psi
qconf
configure --enable-plugins --enable-whiteboarding --with-openssl-inc=%OPENSSLDIR%\include --with-openssl-lib=%OPENSSLDIR%\lib\MinGW --disable-xss --disable-qdbus --with-aspell-inc=%MINGWDIR%\include --with-aspell-lib=%MINGWDIR%\lib --enable-webkit
@echo ================================
@echo Compiler is ready for fight! B-)
@echo ================================
@echo Start time:  %TIME%>..\timestamps.log
mingw32-make
@echo Finish time: %TIME%>>..\timestamps.log
move /Y src\release\psi-plus.exe ..\psi-plus.exe
@goto exit

:rejected
@echo ===========================================================================
@echo Some patches (%count%) are rejected. Look at the generated rejected_* files
@echo ===========================================================================

:exit
pause & pause
