#!/bin/bash
#######################################################################
#                                                                     #
#       Universal build script of Psi+ under MacOS X                  #
#       Универсальный скрипт сборки Psi+ под MacOS X                  #
#                                                                     #
#######################################################################

# REQUIREMENTS / ТРЕБОВАНИЯ

# In order to build Psi+ you must have next packages in your system
# Для сборки Psi+ вам понадобятся следующие пакеты
# git - vcs system / система контроля версий
# gcc - compiler / компилятор
# qt4 sdk from qt.nokia.com / qt4 sdk c qt.nokia.com
# qca/QtCrypto - encryption libs / криптовальные либы
# Growl framework / фрэймворк Growl
# Sparkle framework / фреймворк Sparkle

# OPTIONS / НАСТРОЙКИ

# build and store directory / каталог для сорсов и сборки
PSI_DIR="${HOME}/psi"

# psimedia dir / каталог с psimedia
PSI_MEDIA_DIR="${PSI_DIR}/psimedia-svn737-mac"

# psi.app dir / каталог psi.app
PSIAPP_DIR=""

# icons for downloads / иконки для скачивания
ICONSETS="system clients activities moods affiliations roster"

# plugins list / список плагинов
PLUGINS=""
# PLUGINS=`ls ${PSI_DIR}/psi-dev/plugins/generic`

# svn version / версия svn
rev=""

# do git pull on psi git working copy on start
# обновляться с репозитория перед сборкой
FORCE_REPO_UPDATE=1

# log of applying patches / лог применения патчей
PATCH_LOG="${PSI_DIR}/psipatch.log"

# skip patches which applies with errors / пропускать глючные патчи
SKIP_INVALID_PATCH=0

# official repository / репозиторий официальной Psi
GIT_REPO_PSI=git://git.psi-im.org/psi.git

# psi-dev repository / репозиторий Psi+
SVN_REPO_PSI_DEV="http://psi-dev.googlecode.com/svn/trunk"

# enabling WebKit
USING_WEBKIT=0

# using Xcode
USING_XCODE=0

# upload to GoogleCode
UPLOAD=0

# configure options / опции скрипта configure
CONF_OPTS=""

# GoogleCode username / имя пользователя на GoogleCode
GCUSER="username"

# GoogleCode password / пароль на GoogleCode
GCPASS="password"

export QMAKESPEC="macx-g++"

#######################
# FUNCTIONS / ФУНКЦИИ #
#######################
# Exit with error message
die() { echo; echo " !!!ERROR: ${1}"; exit 1; }

#smart patcher
spatch() {
	popts=""
	PATCH_TARGET="${1}"

	echo -n " * applying ${PATCH_TARGET}..." | tee -a $PATCH_LOG

	if (patch -p1 ${popts} --dry-run -i ${PATCH_TARGET}) >> $PATCH_LOG 2>&1
	then
		if (patch -p1 ${popts} -i ${PATCH_TARGET} >> $PATCH_LOG 2>&1)
		then
			echo " done" | tee -a $PATCH_LOG
			return 0
		else
			echo "dry-run ok, but actual failed" | tee -a $PATCH_LOG
		fi
	else
		echo "failed" | tee -a $PATCH_LOG
	fi
	return 1
}

check_env() {
	echo -e "\033[1m* Testing environment...\033[0m"
	v=`git --version 2>/dev/null` || die "You should install Git first. / Сначала установите Git"
	v=`svn --version 2>/dev/null` || die "You should install subversion first. / Сначала установите subversion"
	v=`gmake --version 2>/dev/null`
	MAKE="gmake"
	if [ -z "$v" ]; then
		echo "gmake not found! / gmake не найден!"
		echo -n "trying just make / пробуем просто make.."
		v=`make --version 2>/dev/null`
		MAKE="make"
	fi
	[ ! -z "$v" ] || die "You should install GNU Make first / Сначала установите GNU Make"
	for qc in qt-qconf qconf; do
		v=`$qc --version 2>/dev/null |grep affinix` && QCONF=$qc
	done
	[ -z "${QCONF}" ] && die "You should install qconf(http://delta.affinix.com/qconf/) / Сначала установите qconf"
	echo "OK"
}

prepare_workspace() {
	echo -e "\033[1m* Init directories...\033[0m"
	if [ ! -d "${PSI_DIR}" ]
	then
		mkdir "${PSI_DIR}" || die "can't create work directory ${PSI_DIR}"
	fi
	rm -rf "${PSI_DIR}"/build

	if [ -e "${PATCH_LOG}" ]
	then
		rm ${PATCH_LOG}
	fi
	[ -d "${PSI_DIR}"/build ] && die "can't delete old build directory ${PSI_DIR}/build"
	mkdir "${PSI_DIR}"/build || die "can't create build directory ${PSI_DIR}/build"
	echo "OK"
}

fetch_sources() {
	cd "${PSI_DIR}"
	if [ -d "git/.git" ]
	then
		echo -e "\033[1m* Starting updating...\033[0m"
		cd git
		if [ $FORCE_REPO_UPDATE != 0 ]; then
			git pull || die "git update failed"
			git submodule init # just in case
		else
			echo "Update disabled in options"
		fi
	else
		echo -e "\033[1m* New fresh repo...\033[m"
		git clone "${GIT_REPO_PSI}" git || die "git clone failed"
		cd git
		git submodule init
	fi
	git submodule update || die "git submodule update failed"

	cd "${PSI_DIR}"

	if [ -d "psi-dev/.svn" ]
	then
		echo -e "\033[1m* Starting psi-dev updating...\033[0m"
		if [ $FORCE_REPO_UPDATE != 0 ]; then
			cd psi-dev
			svn up || die "svn update failed"
		else
			echo "Update disabled in options"
		fi
	else
		echo -e "\033[1m* New fresh psi-dev repo...\033[0m"
		svn checkout "${SVN_REPO_PSI_DEV}" psi-dev || die "svn checkout failed"
	fi
	export rev=`svnversion ${PSI_DIR}/psi-dev/patches`

	cd "${PSI_DIR}"

	echo -e "\033[1m* Downloading psimedia...\033[0m"
	if [ ! -f psimedia-svn737-mac.tar.bz2 ]; then
		curl -C http://dl.dropbox.com/u/4387941/psi/psimedia/psimedia-svn737-mac.tar.bz2
	fi
	echo -e "\033[1m* Extracting psimedia...\033[0m"
	if [ ! -d ${PSI_MEDIA_DIR} ]; then
		tar -xjf psimedia-svn737-mac.tar.bz2
	fi
}

prepare_sources() {
	echo -e "\033[1m* Exporting sources...\033[0m"
	cd "${PSI_DIR}"/git
	git archive --format=tar HEAD | ( cd "${PSI_DIR}/build" ; tar xf - )
	(
		export ddir="${PSI_DIR}/build"
		git submodule foreach '( git archive --format=tar HEAD ) \
			| ( cd "${ddir}/${path}" ; tar xf - )'
	)

	echo -e "\033[1m* Copying plugins...\033[0m"
	cd "${PSI_DIR}"
	svn export "${PSI_DIR}/psi-dev/plugins/generic" "${PSI_DIR}/build/src/plugins/generic" --force

	echo -e "\033[1m* Applying patches...\033[0m"
	PATCHES=`ls -1 psi-dev/patches/*diff | grep -v "0820-psi-dirty-check.diff" 2>/dev/null`
	PATCHESMACOSX=`ls -1 psi-dev/scripts/macosx/patches/*diff 2>/dev/null`
	cd "${PSI_DIR}/build"
	for p in $PATCHES; do
		spatch "${PSI_DIR}/${p}"
		if [ "$?" != 0 ]
		then
			[ $SKIP_INVALID_PATCH != 0 ] && echo "skip invalid patch"
			[ $SKIP_INVALID_PATCH == 0 ] && die "can't continue due to patch failed"
		fi
	done

	for p in $PATCHESMACOSX; do
		spatch "${PSI_DIR}/${p}"
		if [ "$?" != 0 ]
		then
			[ $SKIP_INVALID_PATCH != 0 ] && echo "skip invalid patch"
			[ $SKIP_INVALID_PATCH == 0 ] && die "can't continue due to patch failed"
		fi
	done

	if [ $USING_WEBKIT != 0 ]; then
		sed -i "" "s/.xxx/.${rev}/" src/applicationinfo.cpp
		sed -i "" "s/configDif/configDir/" src/applicationinfo.cpp
		sed -i "" "s/psi-plus-mac.xml/psi-plus-wk-mac.xml/" src/applicationinfo.cpp
		sed -i "" "s/.xxx/.${rev}-webkit/" mac/Makefile
		sed -i "" "s/QtDBus phonon/QtDBus QtWebKit phonon/" mac/Makefile
		sed -i "" "s/-devel/.${rev}-webkit/g" mac/Info.plist
	else
		sed -i "" "s/.xxx/.${rev}/" src/applicationinfo.cpp
		sed -i "" "s/configDif/configDir/" src/applicationinfo.cpp
		sed -i "" "s/.xxx/.${rev}/" mac/Makefile
		sed -i "" "s/-devel/.${rev}/g" mac/Info.plist
	fi
	sed -i "" "s/<string>psi<\/string>/<string>psi-plus<\/string>/g" mac/Info.plist
	sed -i "" "s/http:\/\/psih.ath.cx\/~bvp\/files/http:\/\/dl.dropbox.com\/u\/4387941\/psi/" src/applicationinfo.cpp
	sed -i "" "s/<\!--<dep type='sparkle'\/>-->/<dep type='sparkle'\/>/g" psi.qc

	cp -f "${PSI_DIR}/psi-dev/scripts/macosx/application.icns" "${PSI_DIR}/build/mac/application.icns"

	svn export "${PSI_DIR}/psi-dev/iconsets" "${PSI_DIR}/build/iconsets" --force
}

src_compile() {
	echo -e "\033[1m* Compiling...\033[0m"
	cd ${PSI_DIR}/build
	$QCONF
	# for Xcode: cd src; qmake; make xcode; xcodebuild -sdk macosx10.5 -configuration Release
	if [ $USING_WEBKIT != 0 ]; then
		export CONF_OPTS="--disable-qdbus --enable-plugins --disable-xss --enable-webkit"
	else
		export CONF_OPTS="--disable-qdbus --enable-plugins --disable-xss"
	fi
	./configure ${CONF_OPTS} || die "configure failed"
	$MAKE sub-third-party-qca-all
	$MAKE sub-iris-all
	cd src
	qmake
	if [ $USING_XCODE != 0 ]; then
	  export PSIAPP_DIR="${PSI_DIR}/build/src/build/Release/psi-plus.app/Contents"
	  $MAKE xcode || die "make failed"
  	xcodebuild -sdk macosx10.5 -configuration Release
	else
	  export PSIAPP_DIR="${PSI_DIR}/build/src/psi-plus.app/Contents"
	  $MAKE $MAKEOPT || die "make failed"
	fi
}

plugins_compile() {
	cd ${PSI_DIR}/build
#	PLUGINS=`ls ${PSI_DIR}/psi-dev/plugins/generic | grep -v contentdownloaderplugin`
	PLUGINS=`ls ${PSI_DIR}/psi-dev/plugins/generic`
	echo -e "\033[1m* List plugins for compiling...\033[0m"
	echo ${PLUGINS}
	echo -e "\033[1m* Compiling plugins...\033[0m"
	for pl in ${PLUGINS}; do
		cd ${PSI_DIR}/build/src/plugins/generic/${pl} && echo -e "\033[1m * Compiling ${pl} plugin.\033[0m" && qmake && make || die "make ${pl} plugin failed"; done
}

copy_resources() {
	echo -e "\033[1m* Copying langpack, web, skins...\033[0m"
	cd ${PSIAPP_DIR}/Resources/
	cp "${PSI_DIR}/psi-dev/lang/ru/psi_ru.qm" psi_ru.qm
	cp "${PSI_DIR}/sign/dsa_pub.pem" dsa_pub.pem
	cp -r ${PSI_DIR}/build/themes .
	cp -r ${PSI_DIR}/build/sound .
	svn export "${PSI_DIR}/psi-dev/skins" "${PSIAPP_DIR}/Resources/skins" --force
	svn export "${PSI_DIR}/psi-dev/sound" "${PSIAPP_DIR}/Resources/sound" --force
	svn export "${PSI_DIR}/psi-dev/certs" "${PSIAPP_DIR}/Resources/certs" --force
	svn export "${PSI_DIR}/psi-dev/themes" "${PSIAPP_DIR}/Resources/themes" --force
	svn export "${PSI_DIR}/psi-dev/iconsets" "${PSIAPP_DIR}/Resources/iconsets" --force
	echo -e "\033[1m* Copying plugins...\033[0m"
	if [ ! -d ${PSIAPP_DIR}/Resources/plugins ]; then
    	mkdir -p "${PSIAPP_DIR}/Resources/plugins"
	fi
	for pl in ${PLUGINS}; do
		cd ${PSI_DIR}/build/src/plugins/generic/${pl} && cp *.dylib ${PSIAPP_DIR}/Resources/plugins/; done

echo -e "\033[1m* Copying psimedia in bundle...\033[0m"
cd ${PSI_MEDIA_DIR}

if [ ! -d ${PSIAPP_DIR}/Frameworks ]; then
	mkdir -p "${PSIAPP_DIR}/Frameworks"
fi
cp Frameworks/*.dylib ${PSIAPP_DIR}/Frameworks
cp -r Frameworks/gstreamer-0.10 ${PSIAPP_DIR}/Frameworks

if [ ! -d ${PSIAPP_DIR}/Plugins ]; then
	mkdir -p "${PSIAPP_DIR}/Plugins"
fi
cp plugins/libgstprovider.dylib ${PSIAPP_DIR}/Plugins

}

make_bundle() {
	echo -e "\033[1m* Making standalone bundle...\033[0m"
	cd ${PSI_DIR}/build/mac && make clean
	cp -f "${PSI_DIR}/psi-dev/scripts/macosx/template.dmg.bz2" "${PSI_DIR}/build/mac/template.dmg.bz2"
	make && make dmg || die "make dmg failed"
	open ${PSI_DIR}/build/mac
	echo -e "\033[1m* You can find bundle in ${PSI_DIR}/build/mac\033[0m"
}

make_appcast() {
	cd ${PSI_DIR}
	if [ $USING_WEBKIT != 0 ]; then
		APPCAST_FILE=psi-plus-wk-mac.xml
		VERSION="0.15."${rev}-webkit
	else
		APPCAST_FILE=psi-plus-mac.xml
		VERSION="0.15."${rev}
	fi
	ARCHIVE_FILENAME=`ls ${PSI_DIR}/build/mac | grep psi-plus`
	echo -e "\033[1m* Uploading dmg on GoogleCode\033[0m"
	if [ $USING_WEBKIT != 0 ]; then
		time googlecode_upload.py -s "Psi+ IM || psi-git `date +"%Y-%m-%d"` || Qt 4.7.3 || WebKit included || Unstable || FOR TEST ONLY" -p psi-dev --labels=WebKit,MacOSX,DiskImage --user=${GCUSER} --password=${GCPASS} ${PSI_DIR}/build/mac/$ARCHIVE_FILENAME || die "uploading failed"
#		echo "Psi+ IM || psi-git `date +"%Y-%m-%d"` || Qt 4.7.3 || WebKit included || Unstable || FOR TEST ONLY"
	else
		time googlecode_upload.py -s "Psi+ IM || psi-git `date +"%Y-%m-%d"` || Qt 4.7.3 || Beta" -p psi-dev --labels=Featured,MacOSX,DiskImage --user=${GCUSER} --password=${GCPASS} ${PSI_DIR}/build/mac/$ARCHIVE_FILENAME || die "uploading failed"
#		echo "Psi+ IM || psi-git `date +"%Y-%m-%d"` || Qt 4.7.3 || Beta"
	fi

	echo -e "\033[1m* Making appcast file...\033[0m"
	DOWNLOAD_BASE_URL="http://psi-dev.googlecode.com/files"

	DOWNLOAD_URL="$DOWNLOAD_BASE_URL/$ARCHIVE_FILENAME"
	KEYCHAIN_PRIVKEY_NAME="Sparkle Private Key 1"

	SIZE=`ls -lR ${PSI_DIR}/build/mac/disk/Psi\+.app | awk '{sum += $5} END{print sum}'`
	PUBDATE=$(LC_TIME=en_US date +"%a, %d %b %G %T %z")
	cd ${PSI_DIR}/build/mac/

	osversionlong=`sw_vers -productVersion`
	osvers=${osversionlong:3:1}

	if [ $osvers -eq 5 ]
	then
	  SIGNATURE=$(
		  openssl dgst -sha1 -binary < "$ARCHIVE_FILENAME" \
			  | openssl dgst -dss1 -sign <(security find-generic-password -g -s "$KEYCHAIN_PRIVKEY_NAME" 2>&1 1>/dev/null | perl -pe '($_) = /"(.+)"/; s/\\012/\n/g') \
			  | openssl enc -base64
	  )
	elif [ $osvers -eq 6 ]
	then
	  SIGNATURE=$(
		  openssl dgst -sha1 -binary < "$ARCHIVE_FILENAME" \
			  | openssl dgst -dss1 -sign <(security find-generic-password -g -s "$KEYCHAIN_PRIVKEY_NAME" 2>&1 1>/dev/null | perl -pe '($_) = /"(.+)"/; s/\\012/\n/g' | perl -MXML::LibXML -e 'print XML::LibXML->new()->parse_file("-")->findvalue(q(//string[preceding-sibling::key[1] = "NOTE"]))') \
			  | openssl enc -base64
	  )
	else
	  die "Unknown way of the signature"
	fi

	[ $SIGNATURE ] || { echo Unable to load signing private key with name "'$PRIVKEY_NAME'"; false; }

	REVINFO=`wget -q -O- http://code.google.com/feeds/p/psi-dev/svnchanges/basic| awk 'BEGIN{RS="<title>"}
	/Revision/{
		gsub(/.*<title>|<\/title>.*/,"")
		print "\t<li>" $0
	}'`

cat > ${PSI_DIR}/${APPCAST_FILE} <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
<channel>
    <title>Psi+ ChangeLog</title>
    <link>http://psih.ath.cx/appcast/psi-plus-mac.xml</link>
    <description>Most recent changes with links to updates.</description>
    <language>en</language>
		<item>
		<title>Version $VERSION</title>
		<description><![CDATA[
		<h2>Changes</h2>
		<ul>
${REVINFO}
		</ul>
		]]></description>
		<pubDate>$PUBDATE</pubDate>
		<enclosure
	    	url="$DOWNLOAD_URL"
	    	sparkle:version="$VERSION"
	    	type="application/octet-stream"
	    	length="$SIZE"
	    	sparkle:dsaSignature="$SIGNATURE"
		/>
    	</item>
</channel>
</rss>
EOF

echo -e "\033[1m* You can find appcast in ${PSI_DIR}/${APPCAST_FILE}\033[0m"
cp ${PSI_DIR}/${APPCAST_FILE} ${HOME}/Dropbox/Public/psi/
cp ${PSI_DIR}/${APPCAST_FILE} /Library/WebServer/Documents/appcast/
cp ${PSI_DIR}/build/mac/$ARCHIVE_FILENAME ${HOME}/Desktop/
}

#############
# Go Go Go! #
#############
while [ "$1" != "" ]; do
	case $1 in
		-w | --webkit )		USING_WEBKIT=1
							;;
		-wu | --without-update )		FORCE_REPO_UPDATE=0
							;;
		--upload )		UPLOAD=1
							;;
		-x | --xcode )    USING_XCODE=1
		          ;;
		-h | --help )		echo "usage: $0 [-w | --webkit] [-wu | --without-update] [--upload] | [-h]"
							exit
							;;
		* )					echo "usage: $0 [-w | --webkit] [-wu | --without-update] [--upload] | [-h]"
							exit 1
	esac
	shift
done

starttime=`date "+Start time: %H:%M:%S"`
check_env
prepare_workspace
fetch_sources
prepare_sources
src_compile
plugins_compile
copy_resources
finishtime=`date "+Finish time: %H:%M:%S"`
make_bundle
if [ $UPLOAD != 0 ]; then
make_appcast
fi
echo $starttime
echo $finishtime
