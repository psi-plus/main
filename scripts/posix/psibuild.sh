#!/usr/bin/env sh
#######################################################################
#                                                                     #
#       Universal build script of Psi+ under Linux                    #
#       Универсальный скрипт сборки Psi+ под Linux                    #
#                                                                     #
#######################################################################

# REQUIREMENTS / ТРЕБОВАНИЯ

# In order to build Psi+ you must have next packages in your system
# Для сборки Psi+ вам понадобятся следующие пакеты
# git - vcs system / система контроля версий
# gcc - compiler / компилятор
# qt4 tools libraries and headers (most probably "dev" packages) / qt4 тулзы либы и хидеры (наверное "dev" пакеты)
# qca/QtCrypto - encryption libs / криптовальные либы
 


# OPTIONS / НАСТРОЙКИ

# build and store directory / каталог для сорсов и сборки
PSI_DIR="${PSI_DIR}" # leave empty for ${HOME}/psi on *nix or /c/psi on windows

# icons for downloads / иконки для скачивания
ICONSETS="system clients activities moods affiliations roster"

# do not update anything from repositories until required
# не обновлять ничего из репозиториев если нет необходимости
WORK_OFFLINE=${WORK_OFFLINE:-0}

# log of applying patches / лог применения патчей
PATCH_LOG="" # PSI_DIR/psipatch.log by default (empty for default)

# skip patches which applies with errors / пропускать глючные патчи
SKIP_INVALID_PATCH="${SKIP_INVALID_PATCH:-0}"

# configure options / опции скрипта configure
CONF_OPTS="${@}"

# install root / каталог куда устанавливать (полезно для пакаджеров)
INSTALL_ROOT="${INSTALL_ROOT:-/}"

# bin directory of compiler cache (all compiler wrappers are there)
CCACHE_BIN_DIR="${CCACHE_BIN_DIR}"

# if system doesn't have qconf package set this variable to
# manually compiled qconf directory.
QCONFDIR="${QCONFDIR}"

# plugins to build
PLUGINS="${PLUGINS:-}"

# checkout libpsibuild
die() { echo "$@"; exit 1; }
if [ ! -f ./libpsibuild.sh -o "$WORK_OFFLINE" = 0 ]; then
  [ -f libpsibuild.sh ] && { rm libpsibuild.sh || die "delete error"; }
  wget --no-check-certificate "https://raw.github.com/psi-plus/main/master/scripts/posix/libpsibuild.sh" || die "Failed to update libpsibuild";
fi
. ./libpsibuild.sh

#############
# Go Go Go! #
#############
check_env $CONF_OPTS
prepare_workspace
fetch_all
prepare_all
compile_all
install_all
