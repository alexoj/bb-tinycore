#!/bin/bash

if [ "x$1" = "x" ]; then
	echo "param needed"
	exit 1
fi

set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/u-boot
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/u-boot/
cp -r u-boot/src BUILD/u-boot

pushd BUILD/u-boot

for i in $ROOT_DIR/u-boot/patch/*.patch; do
	echo $i
	patch -p1 < $i
done

make ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} distclean
make ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} $1
make ARCH=arm CROSS_COMPILE=${CROSS_COMPILE}

popd


