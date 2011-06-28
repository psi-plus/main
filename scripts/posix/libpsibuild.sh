# do not update anything from repositories until required
WORK_OFFLINE=${WORK_OFFLINE:-0}

# skip patches which applies with errors / пропускать глючные патчи
SKIP_INVALID_PATCH=${SKIP_INVALID_PATCH:-0}

# configure options / опции скрипта configure
DEFAULT_CONF_OPTS="${DEFAULT_CONF_OPTS:---enable-plugins --enable-whiteboarding}"
CONF_OPTS="${DEFAULT_CONF_OPTS} ${CONF_OPTS}"

# install root / каталог куда устанавливать (полезно для пакаджеров)
INSTALL_ROOT="${INSTALL_ROOT:-/}"

# icons for downloads / иконки для скачивания
ICONSETS="${ICONSETS:-system clients activities moods affiliations roster}"

# bin directory of compiler cache util (leave empty to try autodetect)
CCACHE_BIN_DIR="${CCACHE_BIN_DIR}"

# available translations
LANGS="ar be bg br ca cs da de ee el eo es et fi fr hr hu it ja mk nl pl pt pt_BR ru se sk sl sr sr@latin sv sw uk ur_PK vi zh_CN zh_TW"

# selected translations (space-separated, leave empty to autodetect by $LANG)
TRANSLATIONS="${TRANSLATIONS}"

# system libraries directory
[ "`uname -m`" = "x86_64" ] && [ -d /usr/lib64 ] && SYSLIBDIRNAME=${SYSLIBDIRNAME:-lib64} || SYSLIBDIRNAME=${SYSLIBDIRNAME:-lib}

# official repository / репозиторий официальной Psi
GIT_REPO_PSI=git://git.psi-im.org/psi.git

GIT_REPO_PLUS=git://github.com/psi-plus/main.git
GIT_REPO_PLUGINS=git://github.com/psi-plus/plugins.git

LANGS_REPO_URI="git://pv.et-inf.fho-emden.de/git/psi-l10n"
RU_LANG_REPO_URI="http://psi-ru.googlecode.com/svn/branches/psi-plus"

SVN_FETCH="${SVN_FETCH:-svn co --trust-server-cert --non-interactive}"
SVN_UP="${SVN_UP:-svn up --trust-server-cert --non-interactive}"

# convert INSTALL_ROOT to absolute path
case "${INSTALL_ROOT}" in /*) ;; *) INSTALL_ROOT="$(pwd)/${INSTALL_ROOT}"; ;; esac
# convert PSI_DIR to absolute path
[ -n "${PSI_DIR}" ] && case "${PSI_DIR}" in /*) ;; *) PSI_DIR="$(pwd)/${PSI_DIR}"; ;; esac

PLUGINS_PREFIXES="${PLUGINS_PREFIXES:-generic}" # will be updated later while detecting platform specific settings
#######################
# FUNCTIONS / ФУНКЦИИ #
#######################

helper() {
  case "${LANG}" in
    "ru_"*) cat <<END
Скрипт для сборки Psi+

-h,--help    Помощь
--enable-webkit Собрать с поддержкой технологий webkit
--prefix=pass    Задать установочный каталог (автоопределение по умолчанию)

    Описание переменных окружения:
PLUGINS="*"           Собрать все плагины
PLUGINS="hello world" Собрать плагины "hello" и "world"
WORK_OFFLINE=[1,0]    Не обновлять из репозитория
SKIP_INVALID_PATCH=[1,0] Пропускать глючные патчи
PATCH_LOG             Лог применения патчей
INSTALL_ROOT          Каталог куда устанавливать (полезно для пакаджеров)
ICONSETS              Иконки для скачивания
CCACHE_BIN_DIR        Каталог кеша компилятора
QCONFDIR              Каталог с банирником qconf при ручной сборке или установке
                      с сайта
SYSLIBDIRNAME         Имя системного каталога с библиотеками (lib64/lib32/lib)
                      Автодетектится если не указана
PLUGINS_PREFIXES      Список префиксов плагинов через пробел (generic/unix/etc)
END
    ;;
    *) cat <<END
Script to build the Psi+

-h,--help    This help
--enable-webkit Build with themed chats and enabled smileys animation
--prefix=pass    Set the installation directory

    Description of environment variables:
PLUGINS="*"           Build all plugins
PLUGINS="hello world" Build plugins "hello" and "world"
WORK_OFFLINE=[1,0]    Do not update anything from repositories until required
SKIP_INVALID_PATCH=[1,0] Skip patches which apply with errors
PATCH_LOG             Log of patching process
INSTALL_ROOT          Install root (usefull for package maintainers)
ICONSETS              Icons to download
CCACHE_BIN_DIR        Bin directory of compiler cache util
QCONFDIR              qconf's binary directory when compiled manually
SYSLIBDIRNAME         System libraries directory name (lib64/lib32/lib)
                      Autodetected when not given
PLUGINS_PREFIXES      Space-separated list of plugin prefixes (generic/unix/etc)
END
  esac
  exit 0
}

# Exit with error message
die() {
  echo; echo " !!!ERROR: $@";
  exit 1;
}

warning() {
  echo; echo " !!!WARNING: $@";
}

winpath2unix() {
  local path="$@"
  local drive=`echo "${path%%:*}" | tr '[A-Z]' '[a-z]'`
  echo "/${drive}/${path#?:\\\\}"
}

check_env() {
  echo "Testing environment.. "

  unset COMPILE_PREFIX
  unset PSILIBDIR
  until [ -z "$1" ]; do
    case "$1" in
      "-h" | "--help")
        helper
        ;;
      "--prefix="*)
        COMPILE_PREFIX=${1#--prefix=}
        ;;
      "--libdir="*)
        PSILIBDIR=${1#--libdir=}
        ;;
    esac
    shift
  done

  # Setting some internal variables
  local have_prefix=0 # compile prefix is set by --prefix argv
  [ -n "${COMPILE_PREFIX}" ] && have_prefix=1

  case "`uname`" in
  FreeBSD)
    MAKEOPT=${MAKEOPT:--j$((`sysctl -n hw.ncpu`+1))}
    STAT_USER_ID='stat -f %u'
    STAT_USER_NAME='stat -f %Su'
    SED_INPLACE_ARG=".bak"
    COMPILE_PREFIX="${COMPILE_PREFIX-/usr/local}"
    CCACHE_BIN_DIR="${CCACHE_BIN_DIR:-/usr/local/libexec/ccache/}"
    PLUGINS_PREFIXES="${PLUGINS_PREFIXES} unix"
    ;;
  SunOS)
    CPUS=`/usr/sbin/psrinfo | grep on-line | wc -l | tr -d ' '`
    if test "x$CPUS" = "x" -o $CPUS = 0; then
      CPUS=1
    fi
    MAKEOPT=${MAKEOPT:--j$CPUS}
    STAT_USER_ID='stat -c %u'
    STAT_USER_NAME='stat -c %U'
    SED_INPLACE_ARG=".bak"
    COMPILE_PREFIX="${COMPILE_PREFIX-/usr/local}"
    PLUGINS_PREFIXES="${PLUGINS_PREFIXES} unix"
    ;;
  MINGW32*)
    local qtpath=`qmake -query QT_INSTALL_PREFIX 2>/dev/null`
    if [ -n "${qtpath}" ]; then
      QTDIR=`winpath2unix "${qtpath}"`
      echo "Qt found in PATH: ${QTDIR}"
      QTSDKPATH=$(cd "${QTDIR}"; cd ../../../../; pwd)
    else
      echo "$(cat <<'CONTENT'
#!/usr/bin/perl
use strict; use warnings;
binmode(STDOUT, ':raw:encoding(UTF-8)');
for my $qfn (@ARGV) { open(my $fh, "<:raw:encoding(UTF-16)", $qfn) or die("Can't open \"$qfn\": $!\n"); print while <$fh>; }
CONTENT
)" > tmp_recode.pl #' generates perl utf16 to utf18 converter
      regedit -e tmp_qtreg.bxt "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\Qt SDK"
      local QTSDKPATH=`perl.exe ./tmp_recode.pl tmp_qtreg.bxt | grep InstallLocation | sed 's:.*="\(.*\)":\1:'`
      rm tmp_recode.pl tmp_qtreg.bxt
      [ -z "${QTSDKPATH}" ] && die "Failed to detect QtSDK path"
      QTSDKPATH=`winpath2unix "${QTSDKPATH}"`
      local versions="$(echo `ls -r "${QTSDKPATH}"/Desktop/Qt/`)"
      QTDIR="${QTSDKPATH}/Desktop/Qt/${versions%% *}/mingw"
    fi
    if [ -n "`mingw32-make --version 2>/dev/null`" ]; then
      MAKE="`which mingw32-make.exe`"
      echo "make found in PATH: ${MAKE}"
    else
      MAKE="${QTSDKPATH}/mingw/bin/mingw32-make.exe"
      [ ! -f "${MAKE}" ] && die "QtSDK path detected but mingw not found"
    fi
    QCONFDIR="${QCONFDIR:-/c/local/QConf}"
    PATH="${QTDIR}/bin:$(dirname ${MAKE}):${PATH}"
    CONFIGURE="configure.exe"
    CONF_OPTS="${CONF_OPTS} --qtdir=${QTDIR}"
    ;;
  *)
    MAKEOPT=${MAKEOPT:--j$((`cat /proc/cpuinfo | grep processor | wc -l`+1))}
    STAT_USER_ID='stat -c %u'
    STAT_USER_NAME='stat -c %U'
    SED_INPLACE_ARG=""
    COMPILE_PREFIX="${COMPILE_PREFIX-/usr}"
    if [ -z "${CCACHE_BIN_DIR}" ]; then
      for d in "/usr/${SYSLIBDIRNAME}/ccache" \
               "/usr/${SYSLIBDIRNAME}/ccache/bin"; do
        [ -x "${d}/gcc" ] && { CCACHE_BIN_DIR="${d}"; break; }
      done
    fi
    PLUGINS_PREFIXES="${PLUGINS_PREFIXES} unix"
    ;;
  esac
   
  PSI_DIR="${PSI_DIR:-${HOME}/psi}"
  PATCH_LOG="${PATCH_LOG:-${PSI_DIR}/psipatch.log}"
  CONFIGURE="${CONFIGURE:-configure}"

  
  v=`git --version 2>/dev/null` || \
    die "You should install Git first. / Сначала установите Git"
  v=`svn --version 2>/dev/null` || \
    die "You should install subversion first. / Сначала установите subversion"

  # Make
  echo -n "Checking for gmake.. "
  if [ ! -f "${MAKE}" ]; then
    MAKE=""
    for gn in gmake make; do
      [ -n "`$gn --version 2>/dev/null`" ] && { MAKE="$gn"; break; }
    done
    [ -z "${MAKE}" ] && die "You should install GNU Make first / "\
            "Сначала установите GNU Make"
  fi
  echo "${MAKE}"

  # patch
  echo -n "Checking for patch.. "
  [ -z "`which patch`" ] &&
    die "patch tool not found / утилита для наложения патчей не найдена"
  # autodetect --dry-run or -C
  [ -n "`patch --help 2>/dev/null | grep dry-run`" ] && PATCH_DRYRUN_ARG="--dry-run" \
    || PATCH_DRYRUN_ARG="-C"
  echo "OK"
  
  find_qt_util() {
    local name=$1
    result=""
    echo -n "Checking for ${name} Qt util.. "
    for un in $name-qt4 qt4-${name} ${name}4 $name; do
      [ -n "`$un -v 2>&1 |grep Qt`" ] && { result="$un"; break; }
    done
    if [ -z "${result}" ]; then
      [ "$nonfatal" = 1 ] || die "You should install $name util as part of"\
        "Qt framework / Сначала установите утилиту $name из Qt framework"
      echo "Not found"
    else
      echo "OK - " $result
    fi
  }

  local result
  # qmake
  find_qt_util qmake; QMAKE="${result}"
  nonfatal=1 find_qt_util lrelease; LRELEASE="${result}"
  find_qt_util moc; # we don't use it dirrectly but its required.
  find_qt_util uic; # we don't use it dirrectly but its required.
  find_qt_util rcc; # we don't use it dirrectly but its required.

  # QConf
  echo -n "Checking for qconf.. "
  if [ -n "${QCONFDIR}" -a -n "`PATH="${PATH}:${QCONFDIR}" qconf 2>/dev/null`" ]; then
    QCONF="${QCONFDIR}/qconf"
  else
    for qc in qt-qconf qconf qconf-qt4; do
      v=`$qc --version 2>/dev/null |grep affinix` && QCONF=$qc
    done
    [ -z "${QCONF}" ] && die "You should install "\
      "qconf(http://delta.affinix.com/qconf/) / Сначала установите qconf"
  fi
  echo "OK - " $QCONF
  
  # CCache
  echo -n "Checking for ccache.. "
  case "`which gcc`" in
    *cache*) echo "already in path. will be used" ;;
    *)
      [ -n "${CCACHE_BIN_DIR}" ] && [ -x "${CCACHE_BIN_DIR}/gcc" ] && {
        echo "Found. going to use it."
        export PATH="${CCACHE_BIN_DIR}:${PATH}";
      } || echo "Not found"
      ;;
  esac

  # Plugins
  validate_plugins_list

  # Language
  validate_translations
  [ -z "${LRELEASE}" ] && warning "lrelease util is not available. so only ready qm files will be installed"

  # Compile prefix
  if [ -n "${COMPILE_PREFIX}" ]; then
    [ $have_prefix = 0 ] && CONF_OPTS="${CONF_OPTS} --prefix=$COMPILE_PREFIX"
    echo "Compile prefix=${COMPILE_PREFIX}"
    if [ -z "${PSILIBDIR}" ]; then # --libdir is not present in argv
      PSILIBDIR="${COMPILE_PREFIX}/lib"
      [ "`uname -m`" = "x86_64" ] && [ -d "${COMPILE_PREFIX}"/lib64 ] && PSILIBDIR="${COMPILE_PREFIX}/lib64"
      CONF_OPTS="${CONF_OPTS} --libdir=${PSILIBDIR}";
    fi
  fi

  echo "Environment is OK"
}

validate_translations() {
  echo -n "Choosing interface language: "
  local selected_langs=""
  [ -z "${TRANSLATIONS}" ] && {
    test_lang() {
      tl=$1
      for l in $LANGS; do
        case "${tl}" in *"$l"*) selected_langs="$l"; return 0; ;; *) ;; esac
      done
      return 1
    }
    test_lang "${LANG%.*}" || test_lang "${LANG%_*}"
  } || {
    local tmp=" $(echo ${LANGS}) "
    for l in ${TRANSLATIONS}; do
      case "${tmp}" in
        *" $l "*) selected_langs="$selected_langs $l" ;;
        *) ;;
      esac
    done
  }
  TRANSLATIONS="$(echo ${selected_langs})"
  echo $TRANSLATIONS
}

validate_plugins_list() {
  local plugins_enabled=0
  case "${CONF_OPTS}" in *--enable-plugins*) plugins_enabled=1; ;; *) ;; esac

  [ -n "${PLUGINS}" ] && [ "${plugins_enabled}" = 0 ] && {
    echo "WARNING: there are selected plugins but plugins are disabled in"
    echo "configuration options. no one will be built"
    PLUGINS=""
  }
}

prepare_workspace() {
  echo -n "Init directories.. "
  if [ ! -d "${PSI_DIR}" ]
  then
    mkdir "${PSI_DIR}" || die "can't create work directory ${PSI_DIR}"
  fi
  rm -rf "${PSI_DIR}"/build
  [ -d "${PSI_DIR}"/build ] && \
    die "can't delete old build directory ${PSI_DIR}/build"
  mkdir "${PSI_DIR}"/build || \
    die "can't create build directory ${PSI_DIR}/build"
  echo "OK"
}

# fetches defined set of something from psi-dev svn. ex: plugins or iconsets
#
# svn_fetch_set(name, remote_path, items, [sub_item_path])
# name - a name of what you ar fetching. for example "plugin"
# remote - a path relative to SVN_BATH_REPO
# items - space separated items string
# sub_item_path - checkout subdirectory of item with this relative path
#
# Example: svn_fetch_set("iconset", "iconsets", "system, mood", "default")
svn_fetch_set() {
  local name="$1"
  local remote="$2"
  local items="$3"
  local subdir="$4"
  local curd=`pwd`
  cd "${PSI_DIR}"
  [ -n "${remote}" ] || die "invalid remote path in set fetching"
  if [ ! -d "${remote}" ]; then
    mkdir -p "${remote}"
  fi
  cd "${remote}"

  for item in ${items}; do
    svn_fetch "${SVN_BASE_REPO}/${remote}/${item}/${subdir}" "$item" \
              "${item} ${name}"
  done
  cd "${curd}"
}

# Checkout fresh copy or update existing from svn
# Example: svn_fetch svn://host/uri/trunk my_target_dir "Something useful"
svn_fetch() {
  local remote="$1"
  local target="$2"
  local comment="$3"
  [ -z "$target" ] && { target="${remote##*/}"; target="${target%%#*}"; }
  [ -z "$target" ] && die "can't determine target dir"
  if [ -d "$target" ]; then
    [ $WORK_OFFLINE = 0 ] && {
      [ -n "$comment" ] && echo -n "Update ${comment} ... "
      $SVN_UP "${target}" || die "${comment} update failed"
    } || true
  else
    [ -n "$comment" ] && echo "Checkout ${comment} .."
    $SVN_FETCH "${remote}" "$target" \
    || die "${comment} checkout failed"
  fi
}

git_fetch() {
  local remote="$1"
  local target="$2"
  local comment="$3"
  local curd=`pwd`
  local forcesubmodule=0
  [ -d "${target}/.git" ] && {
    [ $WORK_OFFLINE = 0 ] && {
      cd "${target}"
      [ -n "${comment}" ] && echo "Update ${comment} .."
      git pull || die "git update failed"
      cd "${curd}"
    } || true
  } || {
    forcesubmodule=1
    echo "Checkout ${comment} .."
    git clone "${remote}" "$target" || die "git clone failed"
  }
  [ $WORK_OFFLINE = 0 -o $forcesubmodule = 1 ] && {
    cd "${target}"
    git submodule update --init || die "git submodule update failed"
  }
  cd "${curd}"
}

fetch_sources() {
  cd "${PSI_DIR}"
  git_fetch "${GIT_REPO_PSI}" git "Psi"
  git_fetch "${GIT_REPO_PLUS}" git-plus "Psi+ additionals"

  local actual_translations=""
  [ -n "$TRANSLATIONS" ] && {
    mkdir -p langs
    for l in $TRANSLATIONS; do
      if [ $l = ru ]; then
        svn_fetch "${RU_LANG_REPO_URI}" "langs/$l" "$l langpack"
      else
        git_fetch "${LANGS_REPO_URI}-$l" "langs/$l" "$l langpack"
      fi
      [ -n "${LRELEASE}" -o -f "langs/$l/psi_$l.qm" ] && actual_translations="${actual_translations} $l"
    done
    actual_translations="$(echo $actual_translations)"
    [ -z "${actual_translations}" ] && warning "Translations not found"
  }
}

fetch_plugins_sources() {
  git_fetch "${GIT_REPO_PLUGINS}" plugins "Psi+ plugins"
  [ -z "${PLUGINS}" ] && return 0
  echo "Validate plugins list.."
  local plugins_tmp=""
  local require_all_plugins="$([ "$PLUGINS" = "*" ] && echo 1 || echo 0)"
  local actual_plugins=""
  for plugins_prefix in $PLUGINS_PREFIXES; do
    PLUGINS_ALL=`echo $(ls -F "${PSI_DIR}/plugins/$plugins_prefix" | grep 'plugin/')`
    [ $require_all_plugins = 1 ] && {
      for p in $PLUGINS_ALL; do actual_plugins="$actual_plugins $plugins_prefix/${p%/}"; done
    } || {
      for pn in $PLUGINS; do
        for p in $PLUGINS_ALL; do [ "${p}" = "${pn}plugin/" ] && actual_plugins="$actual_plugins $plugins_prefix/${p%/}"; done
      done
    }
  done
  PLUGINS="${actual_plugins}"
  echo "Enabled plugins:" $(echo $PLUGINS | sed 's:generic/::g')
}

fetch_all() {
  fetch_sources
  fetch_plugins_sources
}

#smart patcher
spatch() {
  PATCH_TARGET="$1"

  echo -n " * applying ${PATCH_TARGET##*/} ..." | tee -a "$PATCH_LOG"

  if (patch -p1 ${PATCH_DRYRUN_ARG} -i "${PATCH_TARGET}") >> "$PATCH_LOG" 2>&1
  then
    if (patch -p1 -i "${PATCH_TARGET}" >> "$PATCH_LOG" 2>&1)
    then
        echo " done" | tee -a "$PATCH_LOG"
    return 0
    else
        echo "dry-run ok, but actual failed" | tee -a "$PATCH_LOG"
    fi
  else
    echo "failed" | tee -a "$PATCH_LOG"
  fi
  return 1
}

prepare_sources() {
  echo "Exporting sources"
  cd "${PSI_DIR}"/git
  git archive --format=tar HEAD | ( cd "${PSI_DIR}/build" ; tar xf - )
  (
    export ddir="${PSI_DIR}/build"
    git submodule foreach "( git archive --format=tar HEAD ) \
        | ( cd \"${ddir}/\${path}\" ; tar xf - )"
  )

  cd "${PSI_DIR}"
  rev="$(cd git-plus; git log -1 --pretty=%h)"
  PATCHES=`ls -1 git-plus/patches/*diff 2>/dev/null`
  cd "${PSI_DIR}/build"
  [ -e "$PATCH_LOG" ] && rm "$PATCH_LOG"
  echo "$PATCHES" | while read p; do
     spatch "${PSI_DIR}/${p}"
     if [ "$?" != 0 ]
     then
       [ $SKIP_INVALID_PATCH = "0" ] \
         && die "can't continue due to patch failed" \
         || echo "skip invalid patch"
     fi
  done
  sed -i${SED_INPLACE_ARG} "s/.xxx/.${rev}/"  src/applicationinfo.cpp
  sed -i${SED_INPLACE_ARG} \
    "s:target.path.*:target.path = ${PSILIBDIR}/psi-plus/plugins:" \
    src/plugins/psiplugin.pri

  # prepare icons
  cp -a "${PSI_DIR}"/git-plus/iconsets "${PSI_DIR}/build"
}

prepare_plugins_sources() {
  [ -d "${PSI_DIR}/build/src/plugins/generic" ] || \
    die "preparing plugins requires prepared psi+ sources"
  for name in ${PLUGINS}; do
    mkdir -p `dirname "${PSI_DIR}/build/src/plugins/$name"`
    cp -a "${PSI_DIR}/plugins/$name" \
      "${PSI_DIR}/build/src/plugins/$name"
  done
}

prepare_all() {
  prepare_sources
  prepare_plugins_sources
}

compile_psi() {
  cd "${PSI_DIR}/build"
  $QCONF
  echo "./${CONFIGURE} ${CONF_OPTS}"
  ./${CONFIGURE} ${CONF_OPTS} || die "configure failed"
  $MAKE $MAKEOPT || die "make failed"
}

compile_plugins() {
  failed_plugins="" # global var

  for name in ${PLUGINS}; do
    echo "Compiling ${name} plugin.."
    cd  "${PSI_DIR}/build/src/plugins/$name"
    $QMAKE "PREFIX=${COMPILE_PREFIX}" && $MAKE $MAKEOPT || {
      echo
      echo "Failed to make plugin ${name}! Skipping.."
      echo
      failed_plugins="${failed_plugins} ${name}"
    }
  done
}

compile_all() {
  compile_psi
  compile_plugins
}

install_psi() {
  case "`uname`" in MINGW*) return 0; ;; esac # disable on windows, must be reimplemented
  echo "Installing psi.."
  BATCH_CODE="${BATCH_CODE}
cd \"${PSI_DIR}/build\";
$MAKE  INSTALL_ROOT=\"${INSTALL_ROOT}\" install || die \"Failed to install Psi+\""
  datadir=`grep PSI_DATADIR "${PSI_DIR}/build/conf.pri" 2>/dev/null`
  datadir="${datadir#*=}"
  if [ -n "${datadir}" ]; then
    cd "${PSI_DIR}"
    for l in $TRANSLATIONS; do
      f="langs/$l/psi_$l"
      [ $l = ru ] && qtf="langs/$l/qt/qt_$l" || qtf="langs/$l/qt_$l"
      [ -n "${LRELEASE}" -a -f "${f}.ts" ] && "${LRELEASE}" "${f}.ts" 2> /dev/null
      [ -n "${LRELEASE}" -a -f "${qtf}.ts" ] && "${LRELEASE}" "${qtf}.ts" 2> /dev/null
      [ -f "${f}.qm" ] && BATCH_CODE="${BATCH_CODE}
cp \"${PSI_DIR}/${f}.qm\" \"${INSTALL_ROOT}${datadir}\""
      [ -f "${qtf}.qm" ] && BATCH_CODE="${BATCH_CODE}
cp \"${PSI_DIR}/${qtf}.qm\" \"${INSTALL_ROOT}${datadir}\""
    done
  fi
  [ "${batch_mode}" = 1 ] || exec_install_batch
}

install_plugins() {
  case "`uname`" in MINGW*) return 0; ;; esac # disable on windows, must be reimplemented
  for name in ${PLUGINS}; do
    case "$failed_plugins" in
      *"$name"*)
        echo "Skipping installation of failed plugin ${name}"
    ;;
      *)
        echo "Installing ${name} plugin.."
        BATCH_CODE="${BATCH_CODE}
cd \"${PSI_DIR}/build/src/plugins/$name\";
$MAKE  INSTALL_ROOT=\"${INSTALL_ROOT}\" install || die \"Failed to install ${name} plugin..\""
        ;;
    esac
  done
  [ "${batch_mode}" = 1 ] || exec_install_batch
}

start_install_batch() {
  batch_mode=1
  BATCH_CODE=""
}

reset_install_batch() {
  batch_mode=0
  BATCH_CODE=""
}

exec_install_batch() {
  cd "${PSI_DIR}"

  echo "#!/usr/bin/env sh
die() {
  echo; echo \" !!!ERROR: \$@\";
  exit 1;
}

mkdir -p \"${INSTALL_ROOT}\" || die \"can't create install root directory ${INSTALL_ROOT}.\";
$BATCH_CODE
" > install.sh
  chmod +x install.sh

  local ir_user=`$STAT_USER_NAME "${INSTALL_ROOT}"`
  [ -z "${ir_user}" ] && die "Failed to detect destination directory's user name"
  if [ "${ir_user}" = "`id -un`" ]; then
    ./install.sh || die "install failed"
  else
    echo "owner of ${INSTALL_ROOT} is ${ir_user} and this is not you."
    priveleged_exec "./install.sh" "${ir_user}"
  fi
  reset_install_batch
}

priveleged_exec() {
  local script="${1}"
  local dest_user="${2}"
  echo "Executing: su -m \"${dest_user}\" -c \"${script}\""
  echo "please enter ${dest_user}'s password.."
  su -m "${dest_user}" -c "${script}" || die "install failed"
}

install_all() {
  start_install_batch
  install_psi
  install_plugins
  exec_install_batch
}
