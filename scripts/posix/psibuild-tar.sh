#!/bin/bash

cho "This script is MUST BE fixed to use git instead of svn"
exit 1

#######################################################################
#                                                                     #
#       Universal make dist script of Psi+ under Linux                #
#       Универсальный скрипт получения дистрибутива Psi+ под Linux    #
#                                                                     #
#######################################################################

# REQUIREMENTS / ТРЕБОВАНИЯ

# In order to build Psi+ you must have next packages in your system
# Для сборки Psi+ вам понадобятся следующие пакеты
# git - vcs system / система контроля версий
# gcc - compiler / компилятор
# qt4 tools libraries and headers (most probably "dev" packages)
#     qt4 тулзы либы и хидеры (наверное "dev" пакеты)
# qca/QtCrypto - encryption libs / криптовальные либы



# OPTIONS / НАСТРОЙКИ

# build and store directory / каталог для сорсов и сборки
#PSI_DIR="${HOME}/psi"
cd `dirname $0`
PSI_DIR=`pwd`

# official repository / репа псины
GIT_REPO_PSI=git://git.psi-im.org/psi.git

# do git pull on psi git working copy on start
# обновляться с репозитория перед сборкой
FORCE_REPO_UPDATE=1

# log of applying patches / лог применения патчей
PATCH_LOG=/tmp/psipatch.log

# only sources / только архив исходного кода
ONLY_SOURCE=1

PATCHTESTOPT="--dry-run"
[ `uname` = FreeBSD ] && PATCHTESTOPT="$PATCHTESTOPT -C"



# FUNCTIONS /функкции

# Exit with error message
die() { echo; echo " !!!ERROR: ${1}"; exit 1; }

# error status
_epatch_assert() { local _pipestatus=${PIPESTATUS[*]}; [[ ${_pipestatus// /} -eq 0 ]] ; }

# Go Go Go!
echo -n "testing environment.."
v=`git --version 2>/dev/null` || die "You should install Git first. / Сначала установите Git"
v=`svn --version 2>/dev/null` || die "You should install subversion first. / Сначала установите subversion"
echo "OK"

echo -n "init directories.."
if [ ! -d "${PSI_DIR}" ]
then
  mkdir "${PSI_DIR}" || die "can't create work directory ${PSI_DIR}"
fi

cd "${PSI_DIR}"
if [ ! -d psi ]
then
  mkdir psi || die "can't create directory for git sources ${PSI_DIR}/psi"
fi
if [ -d build ]
then
  echo -n "removing old build directory.."
  rm -rf build || die "can't delete old build directory ${PSI_DIR}/build"
fi
mkdir build || die "can't create build directory ${PSI_DIR}/build"
echo "OK"

if [ -d "psi/.git" ]
then
  echo "Starting updating.."
  cd psi
  if [ $FORCE_REPO_UPDATE != 0 ]; then
    git pull || die "git update failed"
    git submodule update || die "git submodule update failed"
  else
    echo "Update disabled in options"
  fi
else
  echo "New fresh repo.."
  git clone "${GIT_REPO_PSI}" || die "git clone failed"
  cd psi
  git submodule init || die "git submodule init failed"
  git submodule update || die "git submodule update failed"
fi

echo "exporting sources"
cd "${PSI_DIR}"/psi
git archive --format=tar HEAD | ( cd "${PSI_DIR}/build" ; tar xf - )
(
	export ddir="${PSI_DIR}/build"
	git submodule foreach '( git archive --format=tar HEAD ) | ( cd "${ddir}/${path}" ; tar xf - )'
)
echo "downloading psi+.."

cd "${PSI_DIR}"
if [ -d psi+ ]
then
  svn up psi+ || die "psi+ update failed"
else
  svn co http://psi-dev.googlecode.com/svn/trunk/ psi+/ \
  	|| die "psi+ checkout failed"
fi

#перекладываем иконки
mv build/iconsets build/iconsets-psi
#импортируем
svn export --force psi+/ build/
#раскладываем иконки
mv build/iconsets build/iconsets-psi-plus
mv build/iconsets-psi build/iconsets
#переложим иконки, так как они вкомпилены патчем
mv build/iconsets-psi-plus/system/default/psiplus build/iconsets/system/default/

PATCHES=`ls -1 build/patches/*diff 2>/dev/null`

cd "${PSI_DIR}/build/patches" && ls -1 *.diff > series

cd "${PSI_DIR}/build"
rev=`svnversion "../psi+"`
sed "s/.xxx/.${rev}/" -i patches/9999-psiplus-application-info.diff

#очищаем виндовый хлам
find "${PSI_DIR}/build" -name 'win32'  | xargs rm -rf $1

#Ну кто так файлы кладет в svn
cp -R "${PSI_DIR}/build/plugins" "${PSI_DIR}/build/src/"
rm -rf "${PSI_DIR}/build/plugins"

#к сожалению из-за лицензии
#rm -rf "${PSI_DIR}/build/iconsets-psi-plus/clients"

rm -rf "${PSI_DIR}/psi-plus-0.15~svn${rev}"
mv "${PSI_DIR}/build" "${PSI_DIR}/psi-plus-0.15~svn${rev}"
cd ${PSI_DIR}
tar -cjf "psi-plus-0.15~svn${rev}.tar.bz2" "psi-plus-0.15~svn${rev}"
rm -rf "${PSI_DIR}/psi-plus-0.15~svn${rev}"
