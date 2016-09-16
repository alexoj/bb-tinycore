#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/iptables
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/iptables
mkdir -p BUILD/iptables

mkdir -p BUILD/iptables/fs
cp -r iptables BUILD/iptables/src

pushd BUILD/iptables/src

./configure --host=$TARGET --prefix=/usr --disable-nftables
make
fakeroot -i $ROOT_DIR/BUILD/fakeroot.env -s $ROOT_DIR/BUILD/fakeroot.env make DESTDIR=$ROOT_DIR/BUILD/iptables/fs install
ln -sf ../sbin/xtables-multi $ROOT_DIR/BUILD/iptables/fs/usr/bin/iptables-xml

popd

