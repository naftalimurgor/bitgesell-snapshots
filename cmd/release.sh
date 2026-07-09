#!/usr/bin/env bash

set -Eeuo pipefail

VERSION="$(date +%d-%m-%y)"

gh release delete "snapshot-${VERSION}" -y >/dev/null 2>&1 || true

gh release create "snapshot-${VERSION}" \
    snapshot/latest.tar.zst \
    snapshot/latest.sha256 \
    snapshot/snapshot.json \
    --title "Snapshot ${VERSION}" \
    --notes "Latest Bitgesell blockchain snapshot."