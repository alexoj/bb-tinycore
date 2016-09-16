#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/wpa_supplicant
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/wpa_supplicant
cp -r wpa_supplicant BUILD/wpa_supplicant
mkdir -p BUILD/wpa_supplicant/fs

cd BUILD/wpa_supplicant/openssl
./config --prefix=/usr --openssldir=/etc/ssl --libdir=/lib shared os/compiler:gcc
make depend
make
make INSTALL_PREFIX=$ROOT_DIR/BUILD/wpa_supplicant/fs install

cd "$ROOT_DIR"
cd BUILD/wpa_supplicant/libnl
autoreconf
./configure --host=$TARGET --prefix=/usr
make
make DESTDIR=$ROOT_DIR/BUILD/wpa_supplicant/fs install

cd "$ROOT_DIR"
cd BUILD/wpa_supplicant/wpa_supplicant/wpa_supplicant
cp defconfig .config
echo "CONFIG_LIBNL32=y" >> .config
echo "CFLAGS += -I$ROOT_DIR/BUILD/wpa_supplicant/fs/usr/include" >> .config
echo "CFLAGS += -I$ROOT_DIR/BUILD/wpa_supplicant/fs/usr/include/libnl3" >> .config
echo "LDFLAGS += -L$ROOT_DIR/BUILD/wpa_supplicant/fs/usr/lib" >> .config
LIBDIR=/usr/lib INCDIR=/usr/include BINDIR=/usr/sbin PKG_CONFIG_PATH="$ROOT_DIR/BUILD/wpa_supplicant/fs/usr/lib/pkgconfig:$ROOT_DIR/BUILD/wpa_supplicant/fs/usr/share/pkgconfig" make CC=${CROSS_COMPILE}gcc V=1
LIBDIR=/usr/lib INCDIR=/usr/include BINDIR=/usr/sbin make DESTDIR=$ROOT_DIR/BUILD/wpa_supplicant/fs install
