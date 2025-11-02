#!/usr/bin/env bash

set -uexo pipefail

mkdir boot
sudo mount -o loop images/fedora_boot.raw boot
sudo mount -o loop images/fedora_esp.raw boot/efi
sudo cp -ar boot/ostree/default-*/dtb boot/efi/dtb
sudo umount -R boot/
rmdir boot
