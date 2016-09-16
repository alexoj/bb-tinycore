#!/bin/bash

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

rm -rf BUILD/kernel/
mkdir -p BUILD/kernel/
mkdir -p BUILD/kernel/modules

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

make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE xconfig
cp .config $ROOT_DIR/kernel/config
popd

rm -rf BUILD/kernel
