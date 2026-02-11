#!/usr/bin/env bash

set -uexo pipefail

if [ $CONF_SPLIT_PARTITIONS = true ] || [ $CONF_INSTALL_DTB = true ]; then
    mkdir images
    [ $CONF_SPLIT_PARTITIONS = true ] && bash $ACTION_PATH/split-partitions.sh
    [ $CONF_INSTALL_DTB = true ] && bash $ACTION_PATH/install-dtb.sh
    sudo chmod 666 images/*
fi

if [ $CONF_SPLIT_PARTITIONS = false ]; then
    sudo kpartx -vafs $FULL_IMAGE/image/disk.raw
    bash $ACTION_PATH/rebuild-esp-inplace.sh
    sudo kpartx -d $FULL_IMAGE/image/disk.raw
    cp $FULL_IMAGE/image/disk.raw ./disk.raw
    sudo chmod 666 disk.raw
fi
