all: sdcard-img

export TARGET := arm-unknown-linux-gnueabihf
export CROSS_COMPILE := arm-unknown-linux-gnueabihf-
export PATH := $(CURDIR)/BUILD/x-tools/arm-unknown-linux-gnueabihf/bin:$(PATH)

.PHONY: toolchain kernel busybox wpa_supplicant eglibc firmware sudo tinycore-utils u-boot udev fs sdcard-fs sdcard-img distclean clwean

# toolchain build
toolchain: BUILD/x-tools
BUILD/x-tools:
	build_scripts/build-toolchain.sh

kernel: BUILD/kernel
BUILD/kernel: BUILD/x-tools
	build_scripts/build-kernel.sh

busybox: BUILD/busybox
BUILD/busybox: BUILD/x-tools
	build_scripts/build-busybox.sh

wpa_supplicant: BUILD/wpa_supplicant
BUILD/wpa_supplicant: BUILD/x-tools
	build_scripts/build-wpa_supplicant.sh

iptables: BUILD/iptables
BUILD/iptables: BUILD/x-tools
	build_scripts/build-iptables.sh

aufs-util: BUILD/aufs-util
BUILD/aufs-util: BUILD/x-tools
	build_scripts/build-aufs-util.sh

eglibc: BUILD/eglibc
BUILD/eglibc: BUILD/x-tools
	build_scripts/build-eglibc.sh

firmware: BUILD/firmware
BUILD/firmware: BUILD/x-tools
	build_scripts/build-firmware.sh

sudo: BUILD/sudo
BUILD/sudo: BUILD/x-tools
	build_scripts/build-sudo.sh

tinycore-utils: BUILD/tinycore-utils
BUILD/tinycore-utils: BUILD/x-tools
	build_scripts/build-tinycore-utils.sh

u-boot: BUILD/u-boot
BUILD/u-boot: BUILD/x-tools
	echo Run make beaglexm or make bbblack, then run make again
	exit 1

beaglexm: BUILD/x-tools
	rm -rf BUILD/u-boot
	rm -rf BUILD/kernel
	cp kernel/config_beaglexm kernel/config
	build_scripts/build-uboot.sh omap3_beagle_defconfig

bbblack: BUILD/x-tools
	rm -rf BUILD/u-boot
	rm -rf BUILD/kernel
	cp kernel/config_bbblack kernel/config
	build_scripts/build-uboot.sh am335x_boneblack_defconfig

udev: BUILD/udev
BUILD/udev: BUILD/x-tools
	build_scripts/build-udev.sh

fs: BUILD/fs
BUILD/fs: BUILD/x-tools BUILD/kernel BUILD/busybox BUILD/wpa_supplicant BUILD/eglibc BUILD/firmware BUILD/sudo BUILD/tinycore-utils BUILD/udev BUILD/iptables BUILD/aufs-util
	build_scripts/build-fs.sh

sdcard-fs: BUILD/sdcard/fs
BUILD/sdcard/fs: BUILD/fs BUILD/u-boot
	build_scripts/build-sdcard-fs.sh

sdcard-img: BUILD/sdcard/img
BUILD/sdcard/img: BUILD/sdcard/fs
	build_scripts/build-sdcard-img.sh

clean:
	find BUILD -maxdepth 1 -mindepth 1 ! -name x-tools -exec chmod -R +w {} \; -exec rm -rf {} \;

distclean:
	chmod -R +w BUILD
	rm -rf BUILD

fromfs:
	rm -rf BUILD/fs
	rm -rf BUILD/sdcard
	make

container:
	docker build -t bb-tinycore_dev build_container

shell:
	docker inspect bb-tinycore_dev >/dev/null 2>&1 || $(MAKE) container
	-docker run --privileged -it -v "$(PWD):/bb-tinycore" -v /dev:/dev -w /bb-tinycore bb-tinycore_dev sh -c "useradd -o -u `id -u` -m user; sudo -u user -i sh -c 'cd /bb-tinycore; bash --login'"
