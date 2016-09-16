#!/bin/bash
set -eux

echo "If this build step fails, you need to be root and outside any containers"

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/sdcard/img
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/sdcard/img
mkdir -p BUILD/sdcard/img

# dd of=BUILD/sdcard/img/sd.img bs=1 seek=1920991232 count=0
dd of=BUILD/sdcard/img/sd.img bs=1 seek=153600000 count=0

LOOP_DEVICE=`sudo losetup --show -f BUILD/sdcard/img/sd.img`
if [ $? -ne 0 ]; then
	exit 1
fi

echo "
o
n
p
1

+32M
n
p
2


t
1
6
t
2
83
p
a
1
w
" | sudo fdisk $LOOP_DEVICE || true
sudo sync
sudo losetup -d $LOOP_DEVICE

LOOP_DEVICE=`sudo losetup --show -f BUILD/sdcard/img/sd.img`
if [ $? -ne 0 ]; then
	exit 1
fi

sudo partx -a $LOOP_DEVICE

sudo mkfs.msdos -F 16 -I ${LOOP_DEVICE}p1
sudo mkfs.ext2 ${LOOP_DEVICE}p2

mkdir -p BUILD/sdcard/img/mnt

sudo mount ${LOOP_DEVICE}p1 BUILD/sdcard/img/mnt
sudo cp -rv BUILD/sdcard/fs/fat/* BUILD/sdcard/img/mnt/
sudo umount BUILD/sdcard/img/mnt

sudo mount ${LOOP_DEVICE}p2 BUILD/sdcard/img/mnt
sudo cp -r BUILD/sdcard/fs/ext/* BUILD/sdcard/img/mnt/
sudo chown -R root:root BUILD/sdcard/img/mnt/*
sudo umount BUILD/sdcard/img/mnt

rmdir BUILD/sdcard/img/mnt

sudo sync

sudo partx -d $LOOP_DEVICE
sudo losetup -d $LOOP_DEVICE
