#!/usr/bin/env bash

set -uexo pipefail

which 7z

mkdir out
mv images out/

# extra downloads
if [ -f "$DEVICE_PATH/scripts/downloads" ]; then
    $ACTION_PATH/download-extra.sh $DEVICE_PATH/scripts/extra-sources
fi

# custom artifact processing script
export OUT_PATH=$(realpath ./out)
export DEVICE_PATH=$(realpath $DEVICE_PATH)
$DEVICE_PATH/scripts/artifacts.sh

# pack the artifacts
7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" out/*
