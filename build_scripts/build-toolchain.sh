#!/bin/bash

set -eux

unset CROSS_COMPILE
unset TARGET

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
exit 1
	cd "$ROOT_DIR"
	chmod -R u+w BUILD/TEMP_toolchain
	rm -rf BUILD/TEMP_toolchain
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/TEMP_toolchain
mkdir -p BUILD/TEMP_toolchain
mkdir -p BUILD/TEMP_toolchain/home
cp -r toolchain/src/ct-ng-src BUILD/TEMP_toolchain/ct-ng
cd BUILD/TEMP_toolchain/ct-ng
patch -p1 < "$ROOT_DIR/toolchain/src/ct-ng-patches/preconfigure-ports-arm-gnueabihf.patch"
patch -p1 < "$ROOT_DIR/toolchain/src/ct-ng-patches/pagesize-bug-fix.patch"
patch -p1 < "$ROOT_DIR/toolchain/src/ct-ng-patches/shlib-versions-gnueabihf.patch"
cp -r "$ROOT_DIR/toolchain/src/ct-ng-config" defconfig
cp -r "$ROOT_DIR/toolchain/tarballs" tarballs
cp -r "$ROOT_DIR/kernel/src" kernel

autoconf
./configure --enable-local
MAKELEVEL=0 make
./ct-ng defconfig
HOME="${ROOT_DIR}/BUILD/TEMP_toolchain/home" ./ct-ng build

cd "$ROOT_DIR"
chmod -R u+w BUILD/x-tools || true
rm -rf BUILD/x-tools
cp -r BUILD/TEMP_toolchain/home/x-tools BUILD/x-tools
chmod -R u+w BUILD/TEMP_toolchain
rm -rf BUILD/TEMP_toolchain
