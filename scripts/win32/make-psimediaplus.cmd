@echo off
@echo Cloning Psimedia from official repository
svn checkout https://delta.affinix.com/svn/trunk/psimedia
@echo Completed
@echo Creating Psimedia+ Project
svn checkout http://psi-dev.googlecode.com/svn/trunk/patches
@echo Completed
@echo Updating Psimedia to Psimedia+
@echo set revision=>set
svnversion patches>>revision
copy /Y /B set + revision setrevision
"%GITDIR%\bin\tr" -d \n\r<setrevision>setrevision.cmd
call setrevision.cmd & del set & del revision & del setrevision & del setrevision.cmd
cd psimedia
SET patchdir=..\patches\psimedia\
SET patchlist=series.txt
dir /B %patchdir%*.diff |sort>%patchlist%
for /F "delims=" %%v in (%patchlist%) do @"%GITDIR%\bin\patch" -r rejected_%%v.txt -p1<%patchdir%%%v
del series.txt
@for /F "delims=" %%a in ('dir ^| find "rejected_" /C') do @set count=%%a
@if not %count%==0 goto rejected
cd ..
@echo Completed
cd psimedia
qmake
@echo Setting version to release
echo CONFIG += release > conf.pri
@echo ================================
@echo Compiler is ready for fight! B-)
@echo ================================
@echo Start time:  %TIME%>..\timestamps.log
mingw32-make
@echo Finish time: %TIME%>>..\timestamps.log
@goto exit

:rejected
@echo ===========================================================================
@echo Some patches (%count%) are rejected. Look at the generated rejected_* files
@echo ===========================================================================

:exit
pause & pause
