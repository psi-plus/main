#!/bin/sh

echo "This script is MUST BE fixed to use git instead of svn"
exit 1

#desc: build script for psi+
#downloads original psi from git, downloads psi+ patches and resources from svn
#exports and makes debian-package
#(C) Nexor <nexor@ya.ru>

#depends: build_lib, debian/*

#desc: library for building deb packages from svn/git
#(C) Nexor <nexor@ya.ru>

#config defaults:
#build_lib config part:

#0=disable svn/git checking
DO_DOWNLOAD=1

#0=disable build, only export sources
DO_BUILD=1

#1 = run sudo dpkg -i * ...
INSTALL_PKG=0

#1 = copying *.deb to local repository, default - ${HOME}/workspace/repa/ubuntu/pool
COPY_REP=0

#1 = cleanup before build: directory $ID-<version> and files *.deb, *.changes, *.build, *.tar.gz
CLEAN=1

DISTNAMES=""
#DISTNAMES="maverick lucid"
RELEASE="1"
RELEASE_SUFFIX="0"
VERSION_PREFIX=""

#name and email for debian/changelog entry
DEBFULLNAME="Stefan Zerkalica"
DEBEMAIL="zerkalica@gmail.com"


#directory for downloads and builds
WORKSPACE_DIR="${HOME}/workspace/build"

#directory of local repository for exported debs, if COPY_REP=1
DEBS_DIR="${HOME}/workspace/repa/ubuntu/pool"

#main project name, empty for autodetect, needs debian/changelog file
#MID=""
MID="psi-plus"

BUILD_CMD="debuild -us -uc -b"
#BUILD_CMD="debuild -S -sa"

export DEB_BUILD_OPTIONS="ccache parallel=4 nocheck"
#export DH_VERBOSE=1

SVN_OPTS=

UPLOAD_CMD=
#UPLOAD_CMD="dput psi-plus"

#PSI+ config part:
DISABLE_WEBKIT=1

#download sources from this svn/git
#array of string, where item is git_or_svn_url name [*] submodule1 src/submodule2, etc
# * - only download and export, do not make package
TRUNKS="http://psi-dev.googlecode.com/svn/trunk psiplus *
http://psi-dev.googlecode.com/svn/trunk/iconsets/roster/default psiplus/iconsets/roster/default *
http://delta.affinix.com/svn/trunk/psimedia psimediaplugin *
git://github.com/zerkalica/psi-plus-debian.git psi-plus-debian *
git://git.psi-im.org/psi.git psi-plus - iris src/libpsi"

#http://psi-ru.googlecode.com/svn/branches/psi-plus psi-ru *

#Remove this plugins from distribution
RM_PLUGINS="chess python testoptplugin"

#copy this data from psiplus svn to psi-plus main package
COPY_STUFF="iconsets/system/default .
certs/rootcert.xml
iconsets/system/summer-system.jisp
iconsets/moods/silk.jisp
iconsets/clients/fingerprint.jisp"

#uncomment for autocheck packages
#PACKAGES="git-core subversion quilt qconf
#fakeroot build-essential devscripts dpkg-dev debhelper fakeroot make automake autotools-dev qt4-qmake
#libqt4-dev libqca2-dev libxss-dev libaspell-dev zlib1g-dev libsm-dev
#libgstreamer-plugins-base0.10-dev liboil0.3-dev libspeexdsp-dev"

putlog() {
	local MSG="${1}"
	local LEVEL="${2}"
	[ "${LEVEL}" != "1" ] && echo "${MSG}"
	[ "${LEVEL}" != "2" ] && echo "${MSG}" >> ${LOG_FILE}
}

die() {
	putlog " !!!ERROR: ${1}"
	exit 1
}

_init_vars() {
	local CHGL
	local DISTNAME
	SRC_DIR=$(dirname "$0")
	[ "$SRC_DIR" = "." ] && SRC_DIR=$(pwd)
	[ -z "$DISTNAMES" ] && DISTNAMES=$(_get_dist_name)
	if [ -z "$MID" ] ; then 
		echo "$SRC_DIR/debian/changelog"
		if [ -e "$SRC_DIR/debian/changelog" ] ; then
			CHGL="$SRC_DIR/debian/changelog"
		else
			for DISTNAME in $DISTNAMES ; do
				CHGL="$SRC_DIR/debian/$DISTNAME/debian/changelog"
				[ -e "$CHGL" ] && break
			done
		fi
		MID=`sed -n 's/^\([^ ]*\).*/\1/p;q' "$CHGL"`
	fi
	WORK_DIR="${WORKSPACE_DIR}/$MID"
	BUILD_DIR="${WORK_DIR}/build"
	SVN_DIR="${WORK_DIR}/git"
	DATE_SHORT=$(date +"%Y%m%d")
	DATE=$(date -R)
	LOG_FILE="${WORK_DIR}/build-$MID.log.txt"
}

_mkdir() {
	mkdir -p "$1" || die "mkdir $1"
}

_init() {
	_init_vars
	if [ "$COPY_REP"="1" ] ; then
		[ -d "$DEBS_DIR" ] || _mkdir "${DEBS_DIR}"
	fi
	[ -d "$BUILD_DIR" ] || _mkdir "${BUILD_DIR}"
	[ -d "$SVN_DIR" ] || _mkdir "${SVN_DIR}"
	echo "$DATE" > "$LOG_FILE"
}

_download_git() {
	local TRUNK="$1"
	local rID="$2"
	if [ ! -d "${SVN_DIR}/${rID}" ] ; then
		cd "${SVN_DIR}"
		git clone "${TRUNK}" "${rID}" || die "git init failed"
		cd "${SVN_DIR}/${rID}"
		git submodule init || die "git submodule init failed"
	else
		cd "${SVN_DIR}/${rID}"
		git pull || die "git update failed"
	fi
	git submodule update --init || die "git submodule update failed"
}

_download_svn() {
	local TRUNK="$1"
	local rID="$2"
	cd "${SVN_DIR}" && svn $SVN_OPTS co "${TRUNK}" "$rID"
}

_download_auto() {
	local TRUNK
	local rID
	local BN
	echo "${TRUNKS}" | \
	while read TRUNK rID BN; do
		if echo "$TRUNK" | grep -q 'git' ; then
				putlog "git downloading $TRUNK $rID"
			_download_git "$TRUNK" "$rID"
		else
				putlog "svn downloading $TRUNK $rID"
			_download_svn "$TRUNK" "$rID"
		fi
	done
}

_download() {
	_download_auto
}

_version_git() {
	local rID="$1"
	cd "${SVN_DIR}/${rID}" && git describe --tags | sed 's/\([.0-9]*\)[-[:alpha:]]*\([0-9]*\).*/\1.\2/'
}

_revision_svn() {
	local rID="$1"
	cd "${SVN_DIR}" && svnversion "${rID}" | sed s/M//
}

_version_svn() {
	local rID="$1"
	local VERSION=`cat "$SVN_DIR/$rID/src/version.h" 2> /dev/null | sed -n 's/.*_VERSION.*\"\([0-9]*\.[0-9]*\).*/\1/p'`
	echo "${VERSION}.$(_revision_svn "$rID")"
}

_version_auto() {
	local TRUNK
	local rID
	local BN
	local mID="$1"
	echo "${TRUNKS}" | \
	while read TRUNK rID BN; do
		echo "$rID" | grep -q "$mID" || continue
		if echo "$TRUNK" | grep -q 'git' ; then
			_version_git "$rID"
		else
			_version_svn "$rID"
		fi
		break
	done
}

_version() {
	_version_auto "$1"
}

_export_git() {
	local rID="$1"
	local lOUT_DIR="$2"
	local GIT_ADDONS="$3"
	local i
	[ -d "$lOUT_DIR" ] || mkdir -p "$lOUT_DIR"
	putlog "git export: $rID to $lOUT_DIR"
	cd "${SVN_DIR}/${rID}" && git archive --format=tar HEAD | ( cd "$lOUT_DIR" ; tar xf - )

	if [ -n "$GIT_ADDONS" ] ; then
		for i in $GIT_ADDONS ; do
			cd "${SVN_DIR}/${rID}/${i}"
			putlog "git submodule export: ${SVN_DIR}/${rID}/${i}"
			git archive --format=tar HEAD | ( cd "${lOUT_DIR}/${i}" ; tar xf - )
		done
	fi
}

_export_svn() {
	local rID="$1"
	local lOUT_DIR="$2"
	[ -d "$lOUT_DIR" ] && rm -rf "$lOUT_DIR"
	putlog "svn export: $rID to $lOUT_DIR"
	cd "${SVN_DIR}" && svn export "$rID" "$lOUT_DIR"
}

_export_auto() {
	local TRUNK
	local rID
	local BN
	local VERSION
	local OUT_DIR
	local TAR_NAME
	local BUILD_NAME
	local i
	local DISTNAME
	local lRELEASE
	local lBUILD_DIR

#	[ "$CLEAN" = "1" ] && _clean

	[ "$CLEAN" = "1" ] && rm -rf "${BUILD_DIR}"
	_mkdir "${BUILD_DIR}"

	echo "${TRUNKS}" | \
	while read TRUNK rID BN SUBMODULES; do
		VERSION=""
		[ "$BN" = "-" ] && BN=
		[ -n "$BN" ] || VERSION="$(_version "$rID")"

		BUILD_NAME="$(_get_build_name "$rID" "$VERSION")"

			lBUILD_DIR="${BUILD_DIR}"

			OUT_DIR="$lBUILD_DIR/$BUILD_NAME"
			_mkdir "$OUT_DIR"

#			if [ "$CLEAN" = "1" -a -z "$BN" ] ; then
#				for i in "$lBUILD_DIR/$rID"-* ; do
#					if echo "$(basename $i)" | grep -q "$rID-[0-9.]\+\$" ; then
#						putlog "cleaning $i"
#						rm -rf "$i"
#					fi
#				done
#			fi

			if echo "$TRUNK" | grep -q 'git' ; then
				_export_git "$rID" "$OUT_DIR" "$SUBMODULES"
			else
				_export_svn "$rID" "$OUT_DIR"
			fi
			_post_export "$rID" "$OUT_DIR" "$VERSION"

			if	[ ! -n  "$BN" ] ; then
				TAR_NAME="$(_get_build_name "$rID" "$VERSION" "_").orig.tar.gz"
				putlog "making ${TAR_NAME} from ${lBUILD_DIR}/${BUILD_NAME}"
				cd "${lBUILD_DIR}" && tar czf "${TAR_NAME}" "${BUILD_NAME}"

				for DISTNAME in $DISTNAMES ; do
					_mkdir "$lBUILD_DIR/$DISTNAME"
					cp -Rap "$OUT_DIR" "$lBUILD_DIR/$DISTNAME"
					cp "$lBUILD_DIR/${TAR_NAME}" "$lBUILD_DIR/$DISTNAME"

					local nOUT_DIR="$lBUILD_DIR/$DISTNAME/$BUILD_NAME"

					putlog "making package for $DISTNAME"
					lRELEASE="$RELEASE~${DISTNAME}$RELEASE_SUFFIX"
					[ -d "$nOUT_DIR/debian" ] && rm -rf "$nOUT_DIR/debian"
					putlog "making package in $nOUT_DIR/debian"
					_copy_pkg "$rID" "$nOUT_DIR" "$DISTNAME"
						_fixchangelog "${rID}" "$VERSION" "$nOUT_DIR" "$DISTNAME" "$lRELEASE"
					putlog "running prebuild in $nOUT_DIR"
					_pre_build "$rID" "$nOUT_DIR"
					putlog "do debuild in $nOUT_DIR = $DO_BUILD"
					[ "$DO_BUILD" = "1" ] && _build_pkg "$rID" "$nOUT_DIR"
					#BUILD_CMD="debuild -S -sd"
					[ "$CLEAN" = "1" ] && rm -rf "$nOUT_DIR"
  			done

				if [ "$CLEAN" = "1" ] ; then
  				rm -rf "$OUT_DIR"
  				rm "${lBUILD_DIR}/$TAR_NAME"
				fi

			fi

	done
}

_export() {
	_export_auto
}

_clean() {
	local i
	putlog "cleaning in $BUILD_DIR"
	cd "$BUILD_DIR" || die "cd $BUILD_DIR"
	for i in *.diff *.patch *.deb *.changes *.build *.tar.gz ; do
		rm -f "$i"
	done
}

_copy_pkg() {
	local rID="$1"
	local OUT_DIR="$2"
	local DISTNAME="$3"
	local SPEC_DIR="$SRC_DIR/debian"
	[ -e "$SPEC_DIR/$DISTNAME/debian/rules" ] && SPEC_DIR="$SPEC_DIR/$DISTNAME/debian"
	cp -Rap $SPEC_DIR "$OUT_DIR"
}

_get_build_name() {
	local rID="$1"
	local VERSION="$2"
	local SEP="$3"
	local lSEP=""
	[ -n "$SEP" ] || SEP="-"
	[ -n "$VERSION" ] && lSEP="$SEP"
	echo "${rID}${lSEP}${VERSION}"
}

_get_dist_name() {
	if which lsb_release >/dev/null ; then
		lsb_release -cs
	else
		echo "unstable"
	fi
}

_fixchangelog() {
	local rID="$1"
	local VERSION="$2"
	local OUT_DIR="$3"
	local DISTNAME="$4"
	local lRELEASE="$5"
	BUILDDEB_DIR="$OUT_DIR/debian"


	mv "${BUILDDEB_DIR}/changelog" "${BUILDDEB_DIR}/changelog.old"
	cat > "${BUILDDEB_DIR}/changelog" << EOF
${rID} (${VERSION_PREFIX}${VERSION}-${lRELEASE}) ${DISTNAME}; urgency=low

  * New upstream release

 -- ${DEBFULLNAME} <${DEBEMAIL}>  ${DATE}

EOF
	cat "${BUILDDEB_DIR}/changelog.old" >> "${BUILDDEB_DIR}/changelog"
	rm "${BUILDDEB_DIR}/changelog.old"
}

_build_cmd() {
	$BUILD_CMD
}

_build_pkg() {
	local rID="$1"
	local OUT_DIR="$2"
	cd "$OUT_DIR"
	if _build_cmd ; then
		if [ "$COPY_REP" = "1" ] ; then
			rm -f "$DEBS_DIR"/${rID}_*
			rm -f "$DEBS_DIR"/${rID}-*
		fi
	fi
}

_build_end() {
		if [ "$INSTALL_PKG" = "1" ] ; then
			sudo dpkg -i "${BUILD_DIR}"/*.deb
		fi
		if [ "$COPY_REP" = "1" ] ; then
			mv "${BUILD_DIR}"/*.deb "$DEBS_DIR"
		fi
}

_pre_build() {
	echo "."
}

_post_export() {
	echo "."
}

_build_all() {
	_init
	[ -n "$PACKAGES" ] && sudo apt-get install $PACKAGES
	[ "$DO_DOWNLOAD" = "1" ] && _download
	_export

	if [ -n "$UPLOAD_CMD" ] ; then
		for dist in $DISTNAMES ; do
			for i in "${BUILD_DIR}"/$dist/*_source.changes ; do
				$UPLOAD_CMD "$i"
				putlog "Sleeping 300 sec..."
				sleep 300
			done
		done
	fi

	[ "$DO_BUILD" = "1" ] && _build_end
}

#build_lib merge end


patch_psi()	{
	local OUT_DIR="$1"
	local REVISION="$2"
	local p
	putlog "patching"

	ls ${BUILD_DIR}/psiplus/patches/*.diff | sort | sed 's/.*\/\([^/]*\.diff\)/\1/g' > ${BUILD_DIR}/psiplus/patches/series

	mv ${BUILD_DIR}/psiplus/patches ${OUT_DIR}/
	cd "${OUT_DIR}"
	quilt push -af
	rm -rf "${OUT_DIR}/patches"
	rm -rf "${OUT_DIR}"/.pc

	sed 's/<disabled\/>/<required\/>/g' -i "${OUT_DIR}/psi.qc"
	sed '/.*universal.*/,/<\/dep>/ s/<required\/>/<disabled\/>/' -i "${OUT_DIR}/psi.qc"
	if [ "$DISABLE_WEBKIT" = "1" ] ; then
		putlog "disable webkit"
		sed '/.*webkit.*/,/<\/dep>/ s/<required\/>/<disabled\/>/' -i "${OUT_DIR}/psi.qc"
	fi
	sed "s/\(.*define PROG_VERSION .*\)\.xxx/\1.${REVISION}/" -i "${OUT_DIR}/src/applicationinfo.cpp"
}


copy_plugins() {
	local OUT_DIR="$1"
	mv -f "$BUILD_DIR/psiplus/plugins/generic"/* "$OUT_DIR/src/plugins/generic"
	[ -d "$BUILD_DIR/psimediaplugin" ] && mv -f "$BUILD_DIR/psimediaplugin" "$OUT_DIR/src/plugins/generic"
	for i in $RM_PLUGINS ; do
		rm -rf "$OUT_DIR/src/plugins/generic/$i"
	done
}

copy_resources() {
	local OUT_DIR="$1"
	local din
	local fdout
	local dout
	local i
	local shared

	#TODO: fix lintian warnings, remove later
	find "$BUILD_DIR/psiplus" -type f -exec chmod 0644 {} \;

	echo "$COPY_STUFF" | \
	while read i shared; do
		din="$BUILD_DIR/psiplus/$i"
		[ -z "$shared" ] && shared="share"
		fdout="$OUT_DIR/${shared}/${i}"
		dout="$(dirname "$fdout")"
		mkdir -p "$dout"
		cp -rf "$BUILD_DIR/psiplus"/$i "${dout}"
	done

	mkdir -p "$OUT_DIR/lang"
	mv -f "$BUILD_DIR/psiplus/lang/ru/psi_ru.qm" "$OUT_DIR/lang"
	mv -f "$BUILD_DIR/psiplus/skins" "$OUT_DIR"
	rm -rf "$OUT_DIR/skins/mac"

	cd "$BUILD_DIR/psiplus/iconsets"
	find . -type f -name "*.jisp" | sed 's/^\.\///g' | \
	while read i ; do
		putlog "copy psi-plus icons: $i"
		echo "$COPY_STUFF" | grep -q "$i" && continue
		fdout="$OUT_DIR/iconsets-psi-plus/$i"
		mkdir -p "$(dirname "$fdout")"
		cp "$i" "$fdout"
	done
	cp $BUILD_DIR/psiplus/iconsets/roster/default/* $OUT_DIR/iconsets/roster/default/
}

#hook: version
_version() {
	local VERSION=`cat "${SVN_DIR}/psi-plus/src/applicationinfo.cpp" | sed -n 's/^\#define PROG_VERSION\s*\"\([[:digit:].]*\).*/\1/p'`
	echo "${VERSION}~svn$(_revision_svn "psiplus")"
}

#hook: post_export
_post_export() {
	local rID="$1"
	local OUT_DIR="$2"
	if [ "$rID" = "psi-plus" ] ; then
		patch_psi "$OUT_DIR" "$(_revision_svn "psiplus")"
		copy_plugins "$OUT_DIR"
		copy_resources "$OUT_DIR"
	fi
}

#hook: copy_pkg
_copy_pkg() {
	local rID="$1"
	local OUT_DIR="$2"
	local DISTNAME="$3"
	if [ ! -e "$BUILD_DIR/psi-plus-debian/$DISTNAME/debian/rules" ] ; then
		DISTNAME="default"
	fi
  cp -r $BUILD_DIR/psi-plus-debian/$DISTNAME/debian $OUT_DIR/
	chmod +x "$OUT_DIR/debian/rules"
}


_build_all
