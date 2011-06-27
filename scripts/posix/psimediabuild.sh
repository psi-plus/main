#!/bin/sh
# Very simple initial build script for psimedia on Linux

cd ${HOME}
svn co https://delta.affinix.com/svn/trunk/psimedia
cd psimedia

git clone git://github.com/psi-plus/main.git
for i main/patches/psimedia/*.diff
do
	patch -p1 < $i
done

qconf || qt-qconf
./configure
make
