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
@echo Completed
qconf
configure --with-openssl-inc=%OPENSSLDIR%\include --with-openssl-lib=%OPENSSLDIR%\lib\MinGW --disable-xss --disable-qdbus --with-aspell-inc=%QTDIR%\..\mingw\include --with-aspell-lib=%QTDIR%\..\mingw\lib
@echo ================================
@echo Compiler is ready for fight! B-)
@echo ================================
pause
@echo Start time:  %TIME%>..\timestamps.log
mingw32-make
@echo Finish time: %TIME%>>..\timestamps.log
move /Y src\release\psi.exe ..\psi.exe
pause & pause
