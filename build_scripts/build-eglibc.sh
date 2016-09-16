#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/eglibc
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/eglibc
mkdir -p BUILD/eglibc
cp -r eglibc BUILD/eglibc/src
mkdir -p BUILD/eglibc/build
mkdir -p BUILD/eglibc/fs

pushd BUILD/eglibc/build

$ROOT_DIR/BUILD/eglibc/src/configure --host=$TARGET --prefix=/usr
make
make install_root=$ROOT_DIR/BUILD/eglibc/fs install

popd

mkdir -p BUILD/eglibc/fs/lib
pushd BUILD/eglibc/fs/lib

ln -s ld-2.13.so ld-linux.so.3

popd
