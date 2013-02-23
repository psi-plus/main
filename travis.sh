#!/bin/sh
git clone --depth=10 --quiet git://github.com/psi-im/psi psi || exit 1
cd psi
git submodule init
git submodule update
ln -s ../patches .
ls -la

