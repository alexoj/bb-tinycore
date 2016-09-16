(sleep 2; vncviewer localhost:1) &
docker run -it -p 5901:5901 -v $PWD/BUILD/sdcard/img/sd.img:/sd.img qemu-linaro /usr/bin/qemu-system-arm -M beaglexm -m 512 -sd /sd.img --vnc :1 -clock unix -serial stdio -usb -device usb-kbd -device usb-mouse -device usb-net,netdev=mynet0 -netdev user,id=mynet0
