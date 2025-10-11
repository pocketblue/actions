#!/usr/bin/env bash

set -uexo pipefail

mkdir images

sudo kpartx -vafs "./$FULL_IMAGE/image/disk.raw"
sudo dd if=/dev/mapper/loop0p1 of=efipart.vfat bs=1M
sudo dd if=/dev/mapper/loop0p2 of=images/fedora_boot.raw bs=1M
sudo dd if=/dev/mapper/loop0p3 of=images/fedora_rootfs.raw bs=1M

VOLID=$(file efipart.vfat | grep -Eo "serial number 0x.{8}" | cut -d' ' -f3)
truncate -s $ESP_SIZE images/fedora_esp.raw
mkfs.vfat -F 32 -S 4096 -n EFI -i $VOLID images/fedora_esp.raw

mkdir -p esp.old esp.new
sudo mount -o loop efipart.vfat esp.old
sudo mount -o loop images/fedora_esp.raw esp.new

sudo cp -a esp.old/. esp.new/
sudo umount esp.old/

if [ "$INSTALL_DTB" = "true" ]; then
    mkdir boot
    sudo mount -o loop images/fedora_boot.raw boot

    sudo cp -ar boot/ostree/default-*/dtb esp.new/dtb

    sudo umount boot/
    rmdir boot
fi

sudo umount esp.new/
rmdir esp.old esp.new

sudo chmod 666 images/*

# pad the last block to 4096 bytes
dd if=/dev/zero bs=1 count=512 | tee -a images/fedora_rootfs.raw
