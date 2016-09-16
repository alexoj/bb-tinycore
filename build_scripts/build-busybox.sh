#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/busybox
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/busybox
mkdir -p BUILD/busybox

mkdir -p BUILD/busybox/fs
cp -r busybox BUILD/busybox/src

pushd BUILD/busybox/src

make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE defconfig
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE
fakeroot -i $ROOT_DIR/BUILD/fakeroot.env -s $ROOT_DIR/BUILD/fakeroot.env make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE CONFIG_PREFIX=$ROOT_DIR/BUILD/busybox/fs install

popd

