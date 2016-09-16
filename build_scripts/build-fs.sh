#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/fs
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/fs
mkdir -p BUILD/fs

cp -r BUILD/kernel/modules/* BUILD/fs/

mkdir -p BUILD/fs/boot
KERNELVERSION="$(cat BUILD/kernel/KERNELVERSION)"
# cp BUILD/kernel/src/arch/arm/boot/System.map BUILD/fs/boot/System.map-$KERNELVERSION
cp BUILD/kernel/src/.config BUILD/fs/boot/config-$KERNELVERSION

mkdir -p BUILD/fs/lib/firmware/
cp -rpd BUILD/firmware/fs/lib/firmware/rt2870.bin BUILD/fs/lib/firmware/rt2870.bin

cp -rpd BUILD/eglibc/fs/* BUILD/fs/

# udev must be before busybox
cp -rpd BUILD/udev/fs/* BUILD/fs/

cp -rpd BUILD/busybox/fs/* BUILD/fs/
chmod u+s BUILD/fs/bin/busybox

cp -rpd BUILD/wpa_supplicant/fs/* BUILD/fs/
cp -rpd BUILD/sudo/fs/* BUILD/fs/
cp -rpd BUILD/iptables/fs/* BUILD/fs/
cp -rpd BUILD/tinycore-utils/fs/* BUILD/fs/
cp -rpd BUILD/aufs-util/fs/* BUILD/fs/

find BUILD/fs -print0 | xargs -0 -n 1 file | grep "not stripped" | grep -Eo "^[^:]+" | grep -Ev ".*\\.ko" | grep -Ev "fs/lib/firmware/" | xargs -d "\\n" -n 1 ${CROSS_COMPILE}strip || true
find BUILD/fs -name \*.a -delete
find BUILD/fs -name \*.o -delete
find BUILD/fs -name \*.map -delete

rm -rf BUILD/fs/usr/include

cp -rpdf tinycore/* BUILD/fs/
fakeroot -s BUILD/fakeroot.env mkdir -p BUILD/fs/etc/ssl
fakeroot -s BUILD/fakeroot.env mkdir -p BUILD/fs/etc/ssl/certs
cp -rpd certs/* BUILD/fs/etc/ssl/certs/
fakeroot -s BUILD/fakeroot.env chown -R 0:0 BUILD/fs/etc/ssl/certs
find BUILD/fs -name .keep -delete

while read file; do
	cp -pd "$file" BUILD/fs/usr/bin/$(basename $file)
	fakeroot -s BUILD/fakeroot.env chown 0:0 BUILD/fs/usr/bin/$(basename $file) || true
done < <(find docker/bundles/latest/ -name 'docker*' ! -name '*.md5' ! -name '*.sha256')
cp -pd docker/modprobe_wrapper BUILD/fs/usr/local/sbin/modprobe
fakeroot -s BUILD/fakeroot.env chown 0:0 BUILD/fs/usr/local/sbin/modprobe

# make home directory
mkdir -p BUILD/fs/home/tc
chmod 750 BUILD/fs/home/tc
fakeroot -s BUILD/fakeroot.env chown -R 1001:50 BUILD/fs/home/tc
