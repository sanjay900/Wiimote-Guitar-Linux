#!/bin/bash
ver=$(uname -r | cut -d'-' -f1)
if [ ! -f linux-$ver.tar.xz ]; then
    echo "Downloading sources"
    wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-$ver.tar.xz
fi
echo "cleaning working dir"
rm -Rf linux-$ver
echo "extracting"
tar -xJf linux-$ver.tar.xz
cd linux-$ver
echo "Initial build"
make clean && make mrproper
cp /usr/lib/modules/$(uname -r)/build/.config ./
cp /usr/lib/modules/$(uname -r)/build/Module.symvers ./
make EXTRAVERSION=-$(uname -r | cut -d'-' -f2) modules_prepare
echo "Patching"
patch -p1 -i ../patch.diff
echo "Building wiimote lib"
make M=drivers/hid
sudo cp drivers/hid/hid-wiimote.ko /usr/lib/modules/`uname -r`/updates/hid-wiimote.ko
sudo depmod
sudo modprobe -r hid-wiimote
sudo modprobe hid-wiimote
