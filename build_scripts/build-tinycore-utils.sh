#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/tinycore-utils
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/tinycore-utils
mkdir -p BUILD/tinycore-utils/fs/usr/bin

pushd BUILD/tinycore-utils/fs/usr/bin

${CROSS_COMPILE}gcc $ROOT_DIR/tinycore-utils/autoscan-devices.c -o autoscan-devices
${CROSS_COMPILE}gcc $ROOT_DIR/tinycore-utils/rotdash.c -o rotdash

popd
