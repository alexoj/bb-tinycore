#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/sudo
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/sudo
mkdir -p BUILD/sudo
cp -r sudo/src BUILD/sudo/src
mkdir -p BUILD/sudo/fs

pushd BUILD/sudo/src

autoreconf
./configure --host=$TARGET --prefix=/usr
make
fakeroot -i $ROOT_DIR/BUILD/fakeroot.env -s $ROOT_DIR/BUILD/fakeroot.env make DESTDIR=$ROOT_DIR/BUILD/sudo/fs install

popd
