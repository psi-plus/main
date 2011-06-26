@echo off
setlocal

set PSI_GIT=git://git.psi-im.org/psi.git
set PSIPLUS_SVN=http://psi-dev.googlecode.com/svn/trunk
set ICONSETS=system clients activities moods affiliations

@echo Check enviroment
set ORIGCD=%CD%
set ERRORLEVEL=0
if defined GITDIR goto :findSVN
call :getInstallDirFromRegistryWOW64 Git_is1
set GITDIR=%InstallationLocation%bin\

:findSVN
if defined SVNDIR goto :checkUtils
FOR /F "tokens=2,*" %%A IN ('REG QUERY "HKLM\Software\SlikSvn\Install" /v Location ^| findstr Location') DO SET SVNDIR=%%B

:checkUtils
set GIT=%GITDIR%git.exe
set SED=%GITDIR%sed.exe
set PATCH=%GITDIR%patch.exe
set SVN=%SVNDIR%svn.exe
set SVNVERSION=%SVNDIR%svnversion.exe
set WORKDIR=%CD%\psi

if not exist "%SVN%" echo Please set proper SVNDIR before start&goto :failExit
if not exist "%GIT%" echo git.exe not found. Please set GITDIR before start&goto :failExit
if not exist "%PATCH%" echo patch.exe not found. Please set GITDIR before start&goto :failExit
if not exist "%SED%" echo sed.exe not found. Please set GITDIR before start&goto :failExit
mingw32-make --version 2>&1 1>nul
if %ERRORLEVEL% neq 0 echo mingw32-make not found or doesn't work. be sure its in PATH&goto :failExit


@echo Fetching sources
if not exist "%WORKDIR%" mkdir "%WORKDIR%"
cd "%WORKDIR%"
echo Fetching git sources
if not exist git "%GIT%" clone %PSI_GIT% git
cd git
"%GIT%" pull
"%GIT%" submodule update --init

echo Fetching patches
cd "%WORKDIR%"
if not exist patches ( "%SVN%" co %PSIPLUS_SVN%/patches ) else "%SVN%" up patches
if %ERRORLEVEL% neq 0 echo "failed to fetch patches"&goto :failExit
echo Fetching icons
call :fetchSvnList iconset iconsets "%ICONSETS%" default
if %ERRORLEVEL% neq 0 echo "failed to fetch icons"&goto :failExit

echo Prepare sources
if not exist "%WORKDIR%\build" md "%WORKDIR%\build"
cd "%WORKDIR%\build"
if %ERRORLEVEL% neq 0 echo "failed to create build directory"&goto :failExit
cd "%WORKDIR%\git"
"%GIT%" checkout-index -a --f --prefix=%WORKDIR%\build\
cd "%WORKDIR%\git\iris"
"%GIT%" checkout-index -a --f --prefix=%WORKDIR%\build\iris\
cd "%WORKDIR%\git\src\libpsi"
"%GIT%" checkout-index -a --f --prefix=%WORKDIR%\build\src\libpsi\
for %%i in (%ICONSETS%) do  (
	"%SVN%" export "%WORKDIR%\iconsets\%%i" "%WORKDIR%\build\iconsets\%%i" --force
	if %ERRORLEVEL% neq 0 echo icons export failed&goto :failExit
)
cd "%WORKDIR%"\build
FOR /F "usebackq delims==" %%i IN (`dir /B "%WORKDIR%\patches\*.diff"`) DO (
	@echo Apply: %%i
	@echo %%i > "%WORKDIR%\patch.log"
	"%PATCH%" -p1 <  "%WORKDIR%\patches\%%i" >> "%WORKDIR%\patch.log"
	if %ERRORLEVEL% neq 0 echo patch failed&goto :failExit
)

for /F "tokens=*" %%i in ('"%SVNVERSION%" %WORKDIR%\patches') do set psiplusrev=%%i
call :doSed "s/\(xxx\)/%psiplusrev%/" "%WORKDIR%\build\src\applicationinfo.cpp"
if %ERRORLEVEL% neq 0 echo failed to set revision&goto :failExit

cd "%WORKDIR%\build"
- TODO qconf, configure and make here 

goto :exit



::------------------------------------------------------------
::--           FUNCTIONS SECTION
::------------------------------------------------------------

:getInstallDirFromRegistryWOW64         -  finds install path from windows registry. (any app from "Add/Remove software")
setlocal
set is64=0
( for /F "delims==" %%i IN ('REG QUERY  "HKLM\Software\Wow6432Node"') DO set is64=1 ) 2>nul
if %is64% == 1 (goto 64bit) else goto 32bit

:64bit
FOR /F "tokens=2,*" %%A IN ('REG QUERY "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%~1" /v InstallLocation ^| findstr InstallLocation') DO SET InstallationLocation=%%B
goto :getInstallDirFromRegistryWOW64Exit

:32bit
FOR /F "tokens=2,*" %%A IN ('REG QUERY "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1" /v InstallLocation ^| findstr InstallLocation') DO SET InstallationLocation=%%B

:getInstallDirFromRegistryWOW64Exit
( endlocal
 set InstallationLocation=%InstallationLocation%
)
goto :eof





:fetchSvnList        - fetches set of something from svn
setlocal
set name=%~1
set remote=%~2
set items= %~3
set subdir=%~4
cd "%WORKDIR%"
if "%remote%" == "" echo invalid remote&goto :fetchSvnListFailed
if not exist "%remote%" md "%remote%"
cd "%remote%"
for %%i in (%items%) do  (
	@echo Fetch %%i %name%
	if exist %%i ( "%SVN%" up %%i ) else "%SVN%" co %PSIPLUS_SVN%/%remote%/%%i/%subdir% %%i
	if %ERRORLEVEL% neq 0 goto :fetchSvnListFailed
)
endlocal
goto :eof

:fetchSvnListFailed
(	endlocal
	set ERRORLEVEL=1
)
goto :eof




:doSed  -  Simple sed wrapper. Needed in case of sed 3.x
setlocal
set "expr=%~1"
set "fn=%~2"
"%SED%" -e  "%expr%" %fn% > "%fn%.tmp"&move "%fn%.tmp" "%fn%"
(	endlocal
	set ERRORLEVEL=%ERRORLEVEL%
)
goto :eof


:failExit
set ERRORLEVEL=1
:exit
( endlocal
	set ERRORLEVEL=%ERRORLEVEL%
	cd "%ORIGCD%"
)
goto :eof

