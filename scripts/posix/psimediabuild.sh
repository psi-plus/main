#!/bin/sh
# Very simple initial build script for psimedia on Linux

cd ${HOME}
svn co https://delta.affinix.com/svn/trunk/psimedia
cd psimedia

svn co http://psi-dev.googlecode.com/svn/trunk/patches/psimedia patches
for i in patches/*.diff
do
	patch -p1 < $i
done

qconf || qt-qconf
./configure
make
