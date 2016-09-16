#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/kernel
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/kernel/
mkdir -p BUILD/kernel/
mkdir -p BUILD/kernel/modules
mkdir -p BUILD/kernel/headers

cp -r kernel/src BUILD/kernel/src

cp -r kernel/aufs-aufs3-standalone/fs/aufs BUILD/kernel/src/fs/aufs
cp -r kernel/aufs-aufs3-standalone/include/uapi/linux/aufs_type.h BUILD/kernel/src/include/uapi/linux/aufs_type.h


pushd BUILD/kernel/src
for p in $ROOT_DIR/kernel/patch/*.patch; do
	patch -p1 < $p
done
for p in $ROOT_DIR/kernel/aufs-aufs3-standalone/*.patch; do
	patch -p1 < $p
done

cp $ROOT_DIR/kernel/config .config

make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE zImage dtbs modules -j4
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$ROOT_DIR/BUILD/kernel/modules/ modules_install
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE INSTALL_HDR_PATH=$ROOT_DIR/BUILD/kernel/headers/ headers_install
KERNELVERSION=`make --no-print-directory -s ARCH=arm CROSS_COMPILE=$CROSS_COMPILE kernelversion`

popd

echo "$KERNELVERSION" > $ROOT_DIR/BUILD/kernel/KERNELVERSION
