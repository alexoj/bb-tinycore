#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/firmware
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/firmware
mkdir -p BUILD/firmware
cp -r firmware/src BUILD/firmware/src
mkdir -p BUILD/firmware/fs

pushd BUILD/firmware/src

make DESTDIR=$ROOT_DIR/BUILD/firmware/fs install

popd

