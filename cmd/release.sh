#!/usr/bin/env bash

VERSION="$(date +%d-%m-%y)"

gh release create "snapshot-${VERSION}" \
    snapshots/latest.tar.zst \
    snapshots/latest.sha256 \
    snapshots/snapshot-${VERSION}.tar.zst \
    snapshots/snapshot-${VERSION}.tar.zst.sha256 \
    --title "Snapshot ${VERSION}" \
    --notes "Latest Bitgesell blockchain snapshot."