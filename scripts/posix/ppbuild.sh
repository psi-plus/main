# !/bin/bash

echo "This script is MUST BE fixed to use git instead of svn"
exit 1

home=/home/$USER
buildpsi=${home}/build_psi
orig_src=${buildpsi}/psi-plus
patches=${buildpsi}/patches
isloop=1
iswebkit=0
logfile=${buildpsi}/psibuild.log
#
qconfspath ()
{
  if [ ! -f "/usr/bin/qconf" ]
  then
    if [ ! -f "/usr/local/bin/qconf" ]
      then
        echo "Enter the path to qconf directory (Example: /home/me/qconf):"
        read qconfpath
    fi
  fi
}
#
quit ()
{
  echo "===Log End===" >> ${logfile}
  isloop=0
}
#
down_git ()
{
  cd ${buildpsi}
  echo "Downloading psi sources from git"
  git clone git://git.psi-im.org/psi.git psi-plus
  if [ -d "${orig_src}" ]
  then
    cd ${orig_src}
    git submodule init
    git submodule update
  else
    echo "Error in line 33: ${orig_src} directory not found"
    echo "Error in line 33: ${orig_src} directory not found" >> ${logfile}
  fi
}
#
update_git ()
{
  echo "Updating psi sources from git"
  if [ -d "${orig_src}" ]
  then
    cd ${orig_src}
    git submodule update
    git pull
    git submodule update
  else
    echo "Error in line 47: ${orig_src} directory not found"
    echo "Error in line 47: ${orig_src} directory not found" >> ${logfile}
  fi
}
#
down_patches ()
{
  echo "Downloading Psi+ patches from svn"
  cd ${buildpsi}
  svn co http://psi-dev.googlecode.com/svn/trunk/patches/
}
#
down_dicons ()
{
  if [ -d "${orig_src}" ]
  then
    cd ${orig_src}
    echo "Downloading Psi+ default iconsets from svn"
    svn export --force http://psi-dev.googlecode.com/svn/trunk/iconsets/system/default iconsets/system/default
    svn export --force http://psi-dev.googlecode.com/svn/trunk/iconsets/roster/default iconsets/roster/default
  else
    echo "Error in line 68: ${orig_src} directory not found"
    echo "Error in line 68: ${orig_src} directory not found" >> ${logfile}
  fi
}
#
down_plugins ()
{
  if [ -d "${orig_src}" ]
  then
    cd ${orig_src}
    echo "Downloading Psi+ plugins from svn"
    svn co http://psi-dev.googlecode.com/svn/trunk/plugins/generic/ src/plugins/generic
  else
    echo "Error in line 82: ${orig_src} directory not found"
    echo "Error in line 82: ${orig_src} directory not found" >> ${logfile}
  fi
}
#
down_all ()
{
  down_git
  down_patches
  down_dicons
  down_plugins
  cd ${home}
}
#
non_auto_src ()
{
  local loop=1
  while [ ${loop} = 1 ]
  do
    echo "Choose action TODO:"
    echo "--[1] - Donwload psi sources from git"
    echo "--[2] - Update psi sources from git"
    echo "--[3] - Download psi+ patches from svn"
    echo "--[4] - Download psi+ default iconsets from svn"
    echo "--[5] - Download psi+ plugins from svn"
    echo "--[0] - Do nothing"
    read deistvo
    case ${deistvo} in
      "1" ) down_git;;
      "2" ) update_git;;
      "3" ) down_patches;;
      "4" ) down_dicons;;
      "5" ) down_plugins;;
      "0" ) clear
            loop=0;;
    esac
  done
}
#
backup_tar ()
{
  cd ${home}
  tar -pczf build_psi.tar.gz build_psi
}
#
restore_tar ()
{
  cd ${home}
  if [ -f "build_psi.tar.gz" ]
  then
    if [ -d ${buildpsi} ]
    then
       rm -r -f ${buildpsi}
    fi
    tar -xzf build_psi.tar.gz
  else
    echo "Error in line 111: No build_psi.tar.gz file found in ${home}"
    echo "Error in line 111: No build_psi.tar.gz file found in ${home}" >> ${logfile}
  fi
}
#
back_restore()
{
  local loop=1
  while [ ${loop} = 1 ]
  do
    echo "Choose action TODO:"
    echo "--[1] - Backup sources to tar.gz"
    echo "--[2] - Restore sources from tar.gz"
    echo "--[0] - Do nothing"
    read deistvo
    case ${deistvo} in
      "1" ) backup_tar;;
      "2" ) restore_tar;;
      "0" ) clear
            loop=0;;
    esac
  done
}
#
apply_patches ()
{
  if [ -d "${orig_src}" ]
  then
    cd ${orig_src}
    echo "Patching..."
    cat ${patches}/*.diff | patch -p1 
    rev=`svnversion "${patches}"`
    app_info=src/applicationinfo.cpp
    sed "s/\(xxx\)/${rev}/" -i "${app_info}"
  else
    echo "Error in line 126: ${orig_src} directory not found"
    echo "Error in line 126: ${orig_src} directory not found" >> ${logfile}
  fi
}
#
prepare_tar ()
{
  echo "Preparing Psi+ source package to build RPM..."
  rev=`svnversion "${patches}"`
  tar_name=psi-plus-0.15.${rev}
  new_src=${buildpsi}/${tar_name}
  local srcpath=/usr/src/packages/SOURCES
  cp -r ${orig_src} ${new_src}
  if [ -d ${new_src} ]
  then
    cd ${buildpsi}
    tar -pczf ${tar_name}.tar.gz ${tar_name}
    rm -r -f ${new_src}
    if [ -d ${srcpath} ]
    then
      if [ ! -f "${srcpath}/${tar_name}.tar.gz" ]
      then
        cp -u ${buildpsi}/${tar_name}.tar.gz ${srcpath}
      fi
    fi
    echo "Preparing completed"
  else
    echo "Error in line 148: ${new_src} directory not found"
    echo "Error in line 148: ${new_src} directory not found" >> ${logfile}
  fi
}
#
prepare_win ()
{
  echo "Preparing Psi+ source package to build in OS Windows..."
  rev=`svnversion "${patches}"`
  tar_name=psi-plus-0.15.${rev}-win
  new_src=${buildpsi}/${tar_name}
  local winpri=${new_src}/conf_windows.pri
  local mainicon=${patches}/app.ico
  local file_pro=${new_src}/src/src.pro
  local ossl=${new_src}/third-party/qca/qca-ossl.pri
  cp -r ${orig_src} ${new_src}
  if [ -d ${new_src} ]
  then
    cd ${buildpsi}
    sed "s/#CONFIG += qca-static/CONFIG += qca-static\nCONFIG += webkit/" -i "${winpri}"
    sed "s/#DEFINES += HAVE_ASPELL/DEFINES += HAVE_ASPELL/" -i "${winpri}"
    sed "s/LIBS += -lgdi32 -lwsock32/LIBS += -lgdi32 -lwsock32 -leay32/" -i "${ossl}"
    sed "s/#CONFIG += psi_plugins/CONFIG += psi_plugins/" -i "${file_pro}"
    cp -f ${mainicon} ${new_src}/win32/
    makepsi='qconf
configure --enable-plugins --qtdir=%QTDIR% --with-openssl-inc=%OPENSSLDIR%\include --with-openssl-lib=%OPENSSLDIR%\lib\MinGW --disable-xss --disable-qdbus --with-aspell-inc=%QTDIR%\..\mingw\include --with-aspell-lib=%QTDIR%\..\mingw\lib
@echo ================================
@echo Compiler is ready for fight! B-)
@echo ================================
pause
mingw32-make
pause
move /Y src\release\psi.exe ..\psi.exe
pause
@goto exit

:exit
pause'
    makewebkitpsi='qconf
configure --enable-plugins --enable-webkit --qtdir=%QTDIR% --with-openssl-inc=%OPENSSLDIR%\include --with-openssl-lib=%OPENSSLDIR%\lib\MinGW --disable-xss --disable-qdbus --with-aspell-inc=%QTDIR%\..\mingw\include --with-aspell-lib=%QTDIR%\..\mingw\lib
@echo ================================
@echo Compiler is ready for fight! B-)
@echo ================================
pause
mingw32-make
pause
move /Y src\release\psi.exe ..\psi.exe
pause
@goto exit

:exit
pause'
    echo "${makepsi}" > ${new_src}/make-psiplus.cmd
    echo "${makewebkitpsi}" > ${new_src}/make-webkit-psiplus.cmd
    tar -pczf ${tar_name}.tar.gz ${tar_name}
    rm -r -f ${new_src}
    echo "${buildpsi}/${tar_name}.tar.gz was created"
    echo "---${buildpsi}/${tar_name}.tar.gz was created" >> ${logfile}
  else
    echo "Error in line 178: ${new_src} directory not found"
    echo "Error in line 178: ${new_src} directory not found" >> ${logfile}
  fi
}
#
compile_psi ()
{
  echo "Enter install prefix if needed (Default /usr), or press Enter"
  read prefix
  if [ ! ${prefix} -o ${prefix} = "" ]
  then
    prefix=/usr
  fi
  cd ${orig_src}
  qconfspath
  if [ ${qconfpath} ]
  then
    ${qconfpath}/qconf
  else
    qconf
  fi
  if [ ${iswebkit} = 0 ]
  then
    sh ${orig_src}/configure --prefix=${prefix} --enable-plugins
  else
    sh ${orig_src}/configure --prefix=${prefix} --enable-plugins --enable-webkit
  fi
  cd ${orig_src}
  make
  iswebkit=0
}
#
compile_psi_webkit ()
{
  iswebkit=1
  compile_psi
}
#
build_plugins ()
{
  if [ ! -d "${home}/.psi" ]
  then
    cd ${home}
    mkdir .psi
    cd .psi
    mkdir plugins
  fi
  plugs=${orig_src}/src/plugins/generic
  cd ${plugs}
  pluglist=`ls`
  for plug in ${pluglist}
  do
    if [ -d ${plug} ]
    then
      cd ${plug}
      if [ -f "Makefile" ]
      then
        make clean
      fi
      qmake
      make
      solib=`find *.so`
      if [ ${#solib} ]
      then
        cp ${plugs}/${plug}/*.so ${home}/.psi/plugins
      fi
      cd ${plugs}
    fi
  done
}
#
down_skins ()
{ 
  echo "Downloading Psi+ Skins and Themes"
  cd ${home}
  svn co http://psi-dev.googlecode.com/svn/trunk/skins/ .psi/skins
  svn export --force http://psi-dev.googlecode.com/svn/trunk/themes/ .psi/themes
}
#
down_sounds ()
{
  echo "Downloading Psi+ Sounds"
  cd ${home}
  svn co http://psi-dev.googlecode.com/svn/trunk/sound/ .psi/sound
}
#
down_icons ()
{
  echo "Downloading All Psi+ Iconsets"
  cd ${home}
  svn co http://psi-dev.googlecode.com/svn/trunk/iconsets/ .psi/iconsets
}
#
down_locale ()
{
  echo "Downloading Psi+ Russian localization files"
  psiloc="psi_ru.qm"
  qtloc="qt_ru.qm"
  cd ${home}/.psi
  if [ -f "${psiloc}" ]
  then
    rm -f ${psiloc}
  fi
  wget http://psi-ru.googlecode.com/svn/trunk/${psiloc}
  if [ -f "${qtloc}" ]
  then
    rm -f ${qtloc}
  fi  
  wget http://psi-ru.googlecode.com/svn/trunk/qt/${qtloc}
  cd ${home}
}
#
down_add ()
{
  down_skins
  down_sounds
  down_icons
  down_locale
}
#
non_auto_add ()
{
  local loop=1
  while [ ${loop} = 1 ]
  do
    echo "Choose action TODO:"
    echo "--[1] - Donwload psi+ skins and themes"
    echo "--[2] - Download psi+ sound files"
    echo "--[3] - Download psi+ iconsets"
    echo "--[4] - Download psi+ ru-locale files"
    echo "--[0] - Do nothing"
    read deistvo
    case ${deistvo} in
      "1" ) down_skins;;
      "2" ) down_sounds;;
      "3" ) down_icons;;
      "4" ) down_locale;;
      "0" ) clear
            loop=0;;
    esac
  done
}
#
build_deb_package ()
{
    echo "Building Psi+ DEB package with checkinstall"
    rev=`svnversion "${patches}"`
    desc='Psi is a cross-platform powerful Jabber client (Qt, C++) designed for the Jabber power users.
Psi+ - Psi IM Mod by psi-dev@conference.jabber.ru.'
    cd ${orig_src}
    echo "${desc}" > description-pak
    requires=' "libaspell15 (>=0.60)", "libc6 (>=2.7-1)", "libgcc1 (>=1:4.1.1)", "libqca2", "libqt4-dbus (>=4.4.3)", "libqt4-network (>=4.4.3)", "libqt4-qt3support (>=4.4.3)", "libqt4-xml (>=4.4.3)", "libqtcore4 (>=4.4.3)", "libqtgui4 (>=4.4.3)", "libstdc++6 (>=4.1.1)", "libx11-6", "libxext6", "libxss1", "zlib1g (>=1:1.1.4)" '
    sudo checkinstall -D --nodoc --pkgname=psi-plus --pkggroup=net --pkgversion=0.15.${rev} --pkgsource=${orig_src} --maintainer="thetvg@gmail.com" --requires="${requires}"
    cp -f ${orig_src}/*.deb ${buildpsi}
}
#
prepare_spec ()
{
  echo "Creating psi.spec file..."
  specfile='Summary: Client application for the Jabber network
Name: psi-plus
Version: 0.15.xxxx
Release: 1
License: GPL
Group: Applications/Internet
URL: http://code.google.com/p/psi-dev/
Source0: %{name}-%{version}.tar.gz


BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root


BuildRequires: openssl-devel, gcc-c++, zlib-devel
%{!?_without_freedesktop:BuildRequires: desktop-file-utils}


%description
Psi is the premiere Instant Messaging application designed for Microsoft Windows, 
Apple Mac OS X and GNU/Linux. Built upon an open protocol named Jabber,           
si is a fast and lightweight messaging client that utilises the best in open      
source technologies. The goal of the Psi project is to create a powerful, yet     
easy-to-use Jabber/XMPP client that tries to strictly adhere to the XMPP drafts.  
and Jabber JEPs. This means that in most cases, Psi will not implement a feature  
unless there is an accepted standard for it in the Jabber community. Doing so     
ensures that Psi will be compatible, stable, and predictable, both from an end-user 
and developer standpoint.
Psi+ - Psi IM Mod by psi-dev@conference.jabber.ru


%prep
%setup


%build
qconf
./configure --prefix="%{_prefix}" --bindir="%{_bindir}" --datadir="%{_datadir}" --qtdir=$QTDIR --enable-plugins --enable-webkit --no-separate-debug-info
%{__make} %{?_smp_mflags}                                                                                                               


%install
%{__rm} -rf %{buildroot}


%{__make} install INSTALL_ROOT="%{buildroot}"


# Install the pixmap for the menu entry
%{__install} -Dp -m0644 iconsets/system/default/logo_128.png \
    %{buildroot}%{_datadir}/pixmaps/psi.png ||:               


%post
touch --no-create %{_datadir}/icons/hicolor || :
%{_bindir}/gtk-update-icon-cache --quiet %{_datadir}/icons/hicolor || :


%postun
touch --no-create %{_datadir}/icons/hicolor || :
%{_bindir}/gtk-update-icon-cache --quiet %{_datadir}/icons/hicolor || :


%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-, root, root, 0755)
%doc COPYING README TODO
%{_bindir}/psi
%{_datadir}/psi/
%{_datadir}/pixmaps/psi.png
%{_datadir}/applications/psi.desktop
%{_datadir}/icons/hicolor/*/apps/psi.png
%exclude %{_datadir}/psi/COPYING
%exclude %{_datadir}/psi/README
'
  tmp_spec=${buildpsi}/test.spec
  usr_spec="/usr/src/packages/SPECS/psi.spec"
  echo "${specfile}" > ${tmp_spec}
  if [ ! -d "/usr/src/packages/SPECS" ]
  then
    usr_spec=${buildpsi}/psi.spec
  fi
  cp -f ${tmp_spec} ${usr_spec}
}
#
set_spec_ver ()
{ 
  echo "Parsing svn revision to psi.spec"
  if [ -f ${usr_spec} ]
  then
    rev=`svnversion "${patches}"`
    vers="0.15.${rev}"
    sed "s/0\.15\.\xxxx/${vers}/" -i "${usr_spec}"
    echo "Do you want to build WebKit wersion of package [y/n]?"
    read webk
    if [ ${webk} = "n" ]
    then
      sed "s/--enable-webkit/ /" -i "${usr_spec}"
    fi
    qconfspath
    if [ ${qconfpath} ]
    then
      local qconfcmd=${qconfpath}/qconf
      sed "s/qconf/${qconfcmd}/" -i "${usr_spec}"
    fi
  else
    echo "Error in line 419: ${usr_spec} file not found"
    echo "Error in line 419: ${usr_spec} file not found" >> ${logfile}
  fi
}
#
build_rpm_package ()
{
  rev=`svnversion "${patches}"`
  tar_name=psi-plus-0.15.${rev}
  sources=/usr/src/packages/SOURCES
  if [ -f "${sources}/${tar_name}.tar.gz" ]
  then
    prepare_spec
    set_spec_ver
    echo "Building Psi+ RPM package"
    if [ -f "/usr/src/packages/SPECS/psi.spec" ]
    then
      specpath=/usr/src/packages/SPECS
    else
      specpath=${buildpsi}
    fi
    cd ${specpath}
    echo "Do yo want to sign this package by your gpg-key [y/n]"
    read otvet
    if [ ${otvet} = "y" ]
    then
      if [ -f "${home}/.rpmmacros" ]
      then
        rpmbuild -bb --sign psi.spec
        rpmbuild -bs --sign psi.spec
      else
        local mess='Make sure that you have the .rpmmacros file in $HOME directory

---Exaple of .rpmmacros contents---

   %_signature    gpg
   %_gpg_name     uid
   %_gpg_path     /home/$USER/.gnupg
   %packager      UserName <user_email>

--- End ---

uid and path you can get by running command:
   gpg --list-keys

---Try again later---'
        echo "${mess}"
      fi
    else
      rpmbuild -bb psi.spec
      rpmbuild -bs psi.spec
    fi
  else
    echo "Error in line 447: No Psi+ *.tar.gz source package found in ${sources}"
    echo "Error in line 447: No Psi+ *.tar.gz source package found in ${sources}" >> ${logfile}
  fi
}
#
print_menu ()
{
  local menu_text='Choose action TODO!
[1] - Download All needed source files to build psi+
---[11] - Manual download
---[12] - Backup/Restore sources to/from tar.gz
[2] - Apply patches
[3] - Prepare psi+ source package to build in OS Windows
[4] - Build psi+ binary
---[41] - Build psi+ Webkit binary
[5] - Build and install All psi+ plugins (except psimedia)
[6] - Install All Skins, Sounds, Icons, and Ru-locales
---[61] - Manual download
[7] - Build DEB package with checkinstall
[8] - Build openSUSE RPM-package
[9] - Get help on additional actions
[0] - Exit'
  echo "${menu_text}"
}
#
get_help ()
{
echo "---------------HELP-----------------------"
echo "[u] - update and backup sources into tar.gz"
echo "[br] - build rpm package from backup with update"
echo "[pw] - prepare ms-windows package from backup with update"
echo "[b] - build psi+ binary from backup with update"
echo "[bwk] - build psi+ webkit binary from backup with update"
echo "[124] - Download all sources and build psi+ binary"
echo "[1241] - Download all sources and build psi+ webkit binary"
echo "-------------------------------------------"
echo "Press Enter to continue..."
read
}
#
choose_action ()
{
  read vibor
  case ${vibor} in
    "1" ) down_all;;
    "11" ) non_auto_src;;
    "12" ) back_restore;;
    "2" ) apply_patches;;
    "3" ) prepare_win;;
    "4" ) compile_psi;;
    "41" ) compile_psi_webkit;;
    "5" ) build_plugins;;
    "6" ) down_add;;
    "61" ) non_auto_add;;
    "7" ) build_deb_package;;
    "8" ) prepare_tar
              build_rpm_package;;
    "9" ) get_help;;
    "u" ) restore_tar
              update_git
              down_patches
              down_dicons
              down_plugins
              backup_tar;;
    "br" ) restore_tar
              update_git
              down_patches
              down_dicons
              down_plugins
              apply_patches
              prepare_tar
              build_rpm_package;;
    "pw" ) restore_tar
              update_git
              down_patches
              down_dicons
              down_plugins
              apply_patches
              prepare_win;;
    "b" ) restore_tar
              update_git
              down_patches
              down_dicons
              down_plugins
              apply_patches
              compile_psi;;
    "bwk" ) restore_tar
              update_git
              down_patches
              down_dicons
              down_plugins
              apply_patches
              compile_psi_webkit;;
    "124" ) down_all
              apply_patches
              compile_psi;;
    "1241" ) down_all
              apply_patches
              compile_psi_webkit;;
    "0" ) quit;;
  esac
}
#
cd ${home}
if [ ! -d "${buildpsi}" ]
  then
    mkdir build_psi
fi
echo "===Log started===" > ${logfile}
clear
#
while [ ${isloop} = 1 ]
do
  print_menu
  choose_action
done
exit 0
