#!/usr/bin/env bash

set -uexo pipefail

mkdir images

[ $CONF_SPLIT_PARTITIONS = false ] && cp $FULL_IMAGE/image/disk.raw images/disk.raw
[ $CONF_SPLIT_PARTITIONS = true ] && bash $ACTION_PATH/split-partitions.sh
[ $CONF_INSTALL_DTB = true ] && bash $ACTION_PATH/install-dtb.sh

sudo chmod 666 images/*
