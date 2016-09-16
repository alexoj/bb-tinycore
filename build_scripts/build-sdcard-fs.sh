#!/bin/bash
set -eux

ROOT_DIR="$(readlink -f "$(dirname "$0")/..")"
cd "$ROOT_DIR"

function clean_up {
	cd "$ROOT_DIR"
	rm -rf BUILD/sdcard/fs
	exit 1
}
trap clean_up ERR SIGHUP SIGINT

rm -rf BUILD/sdcard/fs
mkdir -p BUILD/sdcard/fs

mkdir -p BUILD/sdcard/fs/ext/boot

KERNELVERSION="$(cat BUILD/kernel/KERNELVERSION)"

cp BUILD/kernel/src/arch/arm/boot/zImage BUILD/sdcard/fs/ext/boot/zImage-$KERNELVERSION
ln -s zImage-$KERNELVERSION BUILD/sdcard/fs/ext/boot/zImage

(cd BUILD/fs; find . -print0 | fakeroot -i ../fakeroot.env cpio -H newc --null -o | gzip -9) > BUILD/sdcard/fs/ext/boot/initramfs-$KERNELVERSION
ln -s initramfs-$KERNELVERSION BUILD/sdcard/fs/ext/boot/initramfs

mkdir -p BUILD/sdcard/fs/ext/boot/dtbs/$KERNELVERSION
cp BUILD/kernel/src/arch/arm/boot/dts/*.dtb BUILD/sdcard/fs/ext/boot/dtbs/

mkdir -p BUILD/sdcard/fs/fat
cp BUILD/u-boot/MLO BUILD/sdcard/fs/fat/
cp BUILD/u-boot/u-boot.img BUILD/sdcard/fs/fat/

echo "bootargs=console=null consoleblank=0 rootfstype=ext2 root=/dev/ram0 noembed drm.debug=7 debug omapdss.debug=1" >> BUILD/sdcard/fs/fat/uEnv.txt
cat <<'EOF' | tr '\n' ' ' >> BUILD/sdcard/fs/fat/uEnv.txt
uenvcmd=echo bb-tinycore load start;
for i in 1 2 3 4 5 6 7 ; do
	setenv mmcpart ${i};
	setenv bootpart ${mmcdev}:${mmcpart};
	if test -e mmc ${bootpart} /boot/zImage; then
		load mmc ${bootpart} ${loadaddr} /boot/zImage;
		load mmc ${bootpart} ${rdaddr} /boot/initramfs; setenv rdsize ${filesize};
		load mmc ${bootpart} ${fdtaddr} /boot/dtbs/${fdtfile};
		bootz ${loadaddr} ${rdaddr}:${rdsize} ${fdtaddr};
	fi;
done
EOF
echo "" >> BUILD/sdcard/fs/fat/uEnv.txt
