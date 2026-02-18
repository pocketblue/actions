#!/usr/bin/env bash

set -uexo pipefail

which mkfs.erofs

ROOTFS_RAW=images/fedora_rootfs.raw
ROOTFS_ERO=rootfs.ero

ROOTFS_MOUNT=$(mktemp -d)
cleanup() {
    if mountpoint -q "$ROOTFS_MOUNT"; then
        sudo umount "$ROOTFS_MOUNT" || true
    fi
    rmdir "$ROOTFS_MOUNT" || true
}
trap cleanup EXIT

if [ "$ROOTFS_TYPE" = "btrfs" ]; then
    MOUNT_OPTS="loop,ro,subvol=root"
else
    MOUNT_OPTS="loop,ro"
fi

sudo mount -o "$MOUNT_OPTS" "$ROOTFS_RAW" "$ROOTFS_MOUNT"
sudo mkfs.erofs -zlz4 -C1048576 "$ROOTFS_ERO" "$ROOTFS_MOUNT"
sudo chown "$(id -u):$(id -g)" "$ROOTFS_ERO"
