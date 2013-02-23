#!/bin/sh
git clone --depth=10 --quiet git://github.com/psi-im/psi psi || exit 1
cd psi
git submodule update --init --recursive || exit 1
ln -s ../patches .
cp -r ../iconsets/* iconsets
cd patches
ls -1 *.diff > series
cd ..
quilt push -a || exit 1
qt-qconf || exit 1
./configure --enable-plugins --enable-whiteboarding --debug --no-separate-debug-info || exit 1
make || exit 1
./configure --enable-plugins --enable-whiteboarding --debug --no-separate-debug-info --enable-webkit || exit 1
make || exit 1


