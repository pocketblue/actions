#!/usr/bin/env bash

set -uexo pipefail

which mkfs.erofs

ROOTFS_TAR=rootfs.tar
ROOTFS_EXTRACT=pocketblue-rootfs
ROOTFS_ERO=rootfs.ero

CTR="$(sudo podman create --rm $OCI_IMAGE /usr/bin/bash)"
sudo podman export "$CTR" > $ROOTFS_TAR

mkdir $ROOTFS_EXTRACT
sudo tar --xattrs-include='*' -p -xf $ROOTFS_TAR -C $ROOTFS_EXTRACT
rm $ROOTFS_TAR

sudo mkfs.erofs -zlz4 -C1048576 $ROOTFS_ERO $ROOTFS_EXTRACT
sudo rm -rf $ROOTFS_EXTRACT

sudo chown "$(id -u):$(id -g)" $ROOTFS_ERO
