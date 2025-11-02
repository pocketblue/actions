#!/usr/bin/env bash

set -uexo pipefail

export UUID=$(sudo blkid -s UUID -o value /dev/mapper/loop0p2)

truncate -s $CONF_BOOT_SIZE images/fedora_boot.raw
sudo mkfs.ext4 -F -L boot -U $UUID images/fedora_boot.raw

mkdir -p boot.old boot.new
sudo mount /dev/mapper/loop0p2 boot.old
sudo mount -o loop images/fedora_boot.raw boot.new
sudo cp -a boot.old/. boot.new/
sudo umount boot.old boot.new
rmdir boot.old boot.new
