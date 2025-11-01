#!/usr/bin/env bash

set -uexo pipefail

mkdir images

if [ "$CONF_SPLIT_PARTITIONS" = "false" ]; then
    cp "./$FULL_IMAGE/image/disk.raw" images/disk.raw
    sudo kpartx -vafs images/disk.raw
    esp_dev=/dev/mapper/loop0p1
    boot_dev=/dev/mapper/loop0p2
else
    sudo kpartx -vafs "./$FULL_IMAGE/image/disk.raw"
    sudo dd if=/dev/mapper/loop0p1 of=efipart.vfat bs=1M
    sudo dd if=/dev/mapper/loop0p2 of=images/fedora_boot.raw bs=1M
    sudo dd if=/dev/mapper/loop0p3 of=images/fedora_rootfs.raw bs=1M

    VOLID=$(file efipart.vfat | grep -Eo "serial number 0x.{8}" | cut -d' ' -f3)
    truncate -s $CONF_ESP_SIZE images/fedora_esp.raw
    mkfs.vfat -F 32 -S 4096 -n EFI -i $VOLID images/fedora_esp.raw

    mkdir -p esp.old esp.new
    sudo mount -o loop efipart.vfat esp.old
    sudo mount -o loop images/fedora_esp.raw esp.new

    sudo cp -a esp.old/. esp.new/
    sudo umount esp.old/
    sudo umount esp.new/
    rmdir esp.old esp.new

    # pad the last block to 4096 bytes
    dd if=/dev/zero bs=1 count=512 | tee -a images/fedora_rootfs.raw

    esp_dev=images/fedora_esp.raw
    boot_dev=images/fedora_boot.raw
fi

if [ "$CONF_INSTALL_DTB" = "true" ]; then
    mkdir boot
    sudo mount -o loop ${boot_dev} boot
    sudo mount -o loop ${esp_dev} boot/efi

    sudo cp -ar boot/ostree/default-*/dtb boot/efi/dtb

    sudo umount -R boot/
    rmdir boot
fi

sudo chmod 666 images/*
