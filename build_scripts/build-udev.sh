#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/udev
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/udev

# libusb
mkdir -p BUILD/udev/libusb/build

pushd BUILD/udev/libusb/build

$ROOT_DIR/udev/libusb/src/configure --host=$TARGET --prefix=$ROOT_DIR/BUILD/udev/depfs/usr --disable-udev
make
make install

popd

# usbutils
mkdir -p BUILD/udev/usbutils/build

pushd BUILD/udev/usbutils/build

PKG_CONFIG_PATH="$ROOT_DIR/BUILD/udev/depfs/usr/lib/pkgconfig:$ROOT_DIR/BUILD/udev/depfs/usr/share/pkgconfig" $ROOT_DIR/udev/usbutils/src/configure --host=$TARGET --prefix=$ROOT_DIR/BUILD/udev/depfs/usr
make
make install

popd

# udev

mkdir -p BUILD/udev/build
cp -r udev/src BUILD/udev/src

pushd BUILD/udev/build

PKG_CONFIG_PATH="$ROOT_DIR/BUILD/udev/depfs/usr/lib/pkgconfig:$ROOT_DIR/BUILD/udev/depfs/usr/share/pkgconfig" $ROOT_DIR/BUILD/udev/src/configure --host=$TARGET --prefix=/ --libdir=/lib --libexecdir=/lib/udev --includedir=/usr/include --datarootdir=/usr/share --with-pci-ids-path=no --with-systemdsystemunitdir=no --disable-gudev --disable-introspection
make
make DESTDIR=$ROOT_DIR/BUILD/udev/fs install

popd

