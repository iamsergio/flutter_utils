#!/bin/sh

# SPDX-FileCopyrightText: 2024 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
# SPDX-License-Identifier: MIT

# Script to print the engine full sha1 and download URL

SHORT_SHA1=`flutter --version | grep 'Engine' | cut -d ' ' -f 4`
FLUTTER_VERSION=`flutter --version | head -n 1 | cut -d ' ' -f 2`

#----------------------
# Change here!
FLUTTER_ENGINE_SOURCE=/data/sources/flutter/engine/src/flutter/
FLUTTER_ENGINE_FOLDER=/data/installation/flutter/flutter-embedder-${FLUTTER_VERSION}
#----------------------

cd $FLUTTER_ENGINE_SOURCE || exit 1

git fetch || exit 1

FULL_SHA1=`git log $SHORT_SHA1 -1 --pretty=format:"%H"`

RELEASE_URL="https://github.com/ardera/flutter-ci/releases/download/engine%2F${FULL_SHA1}/engine-x64-generic-release.tar.xz"
DEBUG_URL="https://github.com/ardera/flutter-ci/releases/download/engine%2F${FULL_SHA1}/engine-x64-generic-debug.tar.xz"
DEBUG_UNOPT_URL="https://github.com/ardera/flutter-ci/releases/download/engine%2F${FULL_SHA1}/engine-x64-generic-debug_unopt.tar.xz"

flutter --version
echo "Engine sha1: $FULL_SHA1"
echo "Release URL: ${RELEASE_URL}"
echo "Debug URL  : ${DEBUG_URL}"

rm -rf $FLUTTER_ENGINE_FOLDER &> /dev/null
mkdir $FLUTTER_ENGINE_FOLDER && cd $FLUTTER_ENGINE_FOLDER && \
echo $FULL_SHA1 > engine.version && \
echo $DEBUG_URL >> engine.version && \
echo $RELEASE_URL >> engine.version && \
mkdir dbg dbg_unopt rel && \
cd dbg && wget $DEBUG_URL && tar xvf engine-x64-generic-debug.tar.xz && \
cd ../dbg_unopt && wget $DEBUG_UNOPT_URL && tar xvf engine-x64-generic-debug_unopt.tar.xz && \
cd ../rel && wget $RELEASE_URL && tar xvf engine-x64-generic-release.tar.xz && \
cd .. && \
cp ${FLUTTER_ENGINE_SOURCE}/shell/platform/embedder/embedder.h flutter_embedder.h && \
rm dbg/engine-x64-generic-debug.tar.xz && rm rel/engine-x64-generic-release.tar.xz && rm dbg_unopt/engine-x64-generic-debug_unopt.tar.xz && \
echo "Installed to ${FLUTTER_ENGINE_FOLDER}"
