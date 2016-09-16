#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
bash
	cd "$ROOT_DIR"
	rm -rf BUILD/aufs-util
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/aufs-util
mkdir -p BUILD/aufs-util

mkdir -p BUILD/aufs-util/fs
cp -r aufs-util BUILD/aufs-util/src

pushd BUILD/aufs-util/src

CC=${CROSS_COMPILE}gcc HOSTCC=gcc CPPFLAGS="-I $ROOT_DIR/BUILD/kernel/headers/include" make
CC=${CROSS_COMPILE}gcc HOSTCC=gcc fakeroot -i $ROOT_DIR/BUILD/fakeroot.env -s $ROOT_DIR/BUILD/fakeroot.env make CPPFLAGS="-I $ROOT_DIR/BUILD/kernel/headers/include" DESTDIR="$ROOT_DIR/BUILD/aufs-util/fs" install

popd

