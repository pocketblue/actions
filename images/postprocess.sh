#!/usr/bin/env bash

set -uexo pipefail

if [ "$CONF_SPLIT_PARTITIONS" = "true" ]; then
    mkdir images
    $ACTION_PATH/split-partitions.sh
    [ "$CONF_INSTALL_DTB" = "true" ] && $ACTION_PATH/install-dtb.sh
    [ "$CONF_BUILD_EROFS" = "true" ] && $ACTION_PATH/build-erofs.sh
    sudo chmod 666 images/*
else
    sudo kpartx -vafs $FULL_IMAGE/image/disk.raw
    $ACTION_PATH/rebuild-esp-inplace.sh
    sudo kpartx -d $FULL_IMAGE/image/disk.raw
    cp $FULL_IMAGE/image/disk.raw ./disk.raw
    sudo chmod 666 disk.raw
fi
