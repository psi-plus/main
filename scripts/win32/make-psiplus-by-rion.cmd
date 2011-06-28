@echo off
setlocal

set PSI_GIT=git://git.psi-im.org/psi.git
set PSI_PLUS_MAIN_GIT=git://github.com/psi-plus/main.git
set PSIPLUS_SVN=http://psi-dev.googlecode.com/svn/trunk
set ICONSETS=system clients activities moods affiliations

@echo Check enviroment
set ORIGCD=%CD%
set ERRORLEVEL=0
if defined GITDIR goto :findSVN
call :getInstallDirFromRegistryWOW64 Git_is1
set GITDIR=%InstallationLocation%bin\

:::findSVN
::if defined SVNDIR goto :checkUtils
::FOR /F "tokens=2,*" %%A IN ('REG QUERY "HKLM\Software\SlikSvn\Install" /v Location ^| findstr Location') DO SET SVNDIR=%%B

:checkUtils
set GIT=%GITDIR%git.exe
set SED=%GITDIR%sed.exe
set PATCH=%GITDIR%patch.exe
::set SVN=%SVNDIR%svn.exe
::set SVNVERSION=%SVNDIR%svnversion.exe
set WORKDIR=%CD%\psi

if defined MINGWDIR goto :ensureExist
call :getInstallDirFromRegistryWOW64 "Qt SDK" HKCU
set GITDIR=%InstallationLocation%bin\
set MINGWDIR=%InstallationLocation%\mingw\bin
set PATH=%MINGWDIR%;%PATH%

:ensureExist
::if not exist "%SVN%" @echo Please set proper SVNDIR before start&goto :failExit
if not exist "%GIT%" @echo git.exe not found. Please set GITDIR before start&goto :failExit
if not exist "%PATCH%" @echo patch.exe not found. Please set GITDIR before start&goto :failExit
if not exist "%SED%" @echo sed.exe not found. Please set GITDIR before start&goto :failExit
( mingw32-make --version 2>&1 ) 1>nul || @echo mingw32-make not found or doesn't work. be sure its in PATH&goto :failExit


@echo Fetching sources
if not exist "%WORKDIR%" mkdir "%WORKDIR%"
cd "%WORKDIR%"
@echo Fetching git sources
if not exist git "%GIT%" clone %PSI_GIT% git
cd git
"%GIT%" pull
"%GIT%" submodule update --init || @echo "failed to fetch Psi repo"&goto :failExit

cd "%WORKDIR%"
@echo Fetching Psi+ main repo
if not exist git-plus "%GIT%" clone %PSI_PLUS_MAIN_GIT% git-plus
cd git-plus
"%GIT%" pull

@echo Prepare sources
if exist "%WORKDIR%\build" rd /S /Q "%WORKDIR%\build" || @echo "failed to remove old build dir"&goto :failExit
md "%WORKDIR%\build" || @echo "failed to make new build dir"&goto :failExit
cd "%WORKDIR%\build"
cd "%WORKDIR%\git"
"%GIT%" checkout-index -a --f --prefix=%WORKDIR%\build\
cd "%WORKDIR%\git\iris"
"%GIT%" checkout-index -a --f --prefix=%WORKDIR%\build\iris\
cd "%WORKDIR%\git\src\libpsi"
"%GIT%" checkout-index -a --f --prefix=%WORKDIR%\build\src\libpsi\
xcopy /Y /E /Q "%WORKDIR%\git-plus\iconsets" "%WORKDIR%\build\iconsets" || @echo icons export failed&goto :failExit
cd "%WORKDIR%"\build
FOR /F "usebackq delims==" %%i IN (`dir /B "%WORKDIR%\git-plus\patches\*.diff"`) DO (
	@echo Apply: %%i
	@echo %%i > "%WORKDIR%\patch.log"
	"%PATCH%" -p1 <  "%WORKDIR%\git-plus\patches\%%i" >> "%WORKDIR%\patch.log" || @echo patch failed&goto :failExit
)

cd "%WORKDIR%"\git-plus
for /f "tokens=2 delims=-" %%i in ('"%GIT%" describe --tags') do set psiplusrev=%%i
call :doSed "s/\(xxx\)/%psiplusrev%/" "%WORKDIR%\build\src\applicationinfo.cpp"
if %ERRORLEVEL% neq 0 @echo failed to set revision&goto :failExit

cd "%WORKDIR%\build"
:: TODO qconf, configure and make here 

goto :exit



::------------------------------------------------------------
::--           FUNCTIONS SECTION
::------------------------------------------------------------

:getInstallDirFromRegistryWOW64         -  finds install path from windows registry. (any app from "Add/Remove software")
setlocal
set root=HKLM
if not %2xxx == xxx set root=%2
set is64=0
( for /F "delims==" %%i IN ('REG QUERY  "HKLM\Software\Wow6432Node"') DO set is64=1 ) 2>nul
if %is64% == 1 (goto 64bit) else goto 32bit

:64bit
FOR /F "tokens=2,*" %%A IN ('REG QUERY "%root%\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%~1" /v InstallLocation ^| findstr InstallLocation') DO SET InstallationLocation=%%B
goto :getInstallDirFromRegistryWOW64Exit

:32bit
FOR /F "tokens=2,*" %%A IN ('REG QUERY "%root%\Software\Microsoft\Windows\CurrentVersion\Uninstall\%~1" /v InstallLocation ^| findstr InstallLocation') DO SET InstallationLocation=%%B

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
if "%remote%" == "" @echo invalid remote&goto :fetchSvnListFailed
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

