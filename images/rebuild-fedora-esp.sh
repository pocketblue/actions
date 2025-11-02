#!/usr/bin/env bash

set -uexo pipefail

export UUID=$(sudo blkid -s UUID -o value /dev/mapper/loop0p1 | tr -d '-')

truncate -s $CONF_ESP_SIZE images/fedora_esp.raw
mkfs.vfat -F 32 -S 4096 -n EFI -i $UUID images/fedora_esp.raw

mkdir -p esp.old esp.new
sudo mount /dev/mapper/loop0p1 esp.old
sudo mount -o loop images/fedora_esp.raw esp.new
sudo cp -a esp.old/. esp.new/
sudo umount esp.old esp.new
rmdir esp.old esp.new
