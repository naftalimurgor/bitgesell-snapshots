#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Usage
########################################

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/.BGL"
    exit 1
fi

SOURCE_DIR="$(realpath "$1")"

[[ -d "$SOURCE_DIR" ]] || {
    echo "Directory not found: $SOURCE_DIR"
    exit 1
}

########################################
# Output
########################################

OUTPUT_DIR="$(pwd)/snapshot"
mkdir -p "$OUTPUT_DIR"

echo "Creating snapshot..."

########################################
# Archive directly (no temp copy)
########################################

PARENT_DIR="$(dirname "$SOURCE_DIR")"
BGL_DIR="$(basename "$SOURCE_DIR")"

tar \
    --exclude="${BGL_DIR}/BGL.conf" \
    --exclude="${BGL_DIR}/BGLd.pid" \
    --exclude="${BGL_DIR}/settings.json" \
    --exclude="${BGL_DIR}/debug.log" \
    --exclude="${BGL_DIR}/mempool.dat" \
    --exclude="${BGL_DIR}/banlist.dat" \
    --exclude="${BGL_DIR}/fee_estimates.dat" \
    --exclude="${BGL_DIR}/wallets" \
    --exclude="${BGL_DIR}/wallet.dat" \
    -cf "$OUTPUT_DIR/latest.tar" \
    -C "$PARENT_DIR" \
    "$BGL_DIR"

########################################
# Compress
########################################

zstd -19 --rm "$OUTPUT_DIR/latest.tar"

########################################
# SHA256
########################################

(
    cd "$OUTPUT_DIR"
    sha256sum latest.tar.zst > latest.sha256
)

########################################
# Metadata (MVP)
########################################

SIZE=$(stat -c%s "$OUTPUT_DIR/latest.tar.zst")
SHA256=$(cut -d' ' -f1 "$OUTPUT_DIR/latest.sha256")

cat > "$OUTPUT_DIR/snapshot.json" <<EOF
{
  "height": 319485,
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "size_bytes": ${SIZE},
  "sha256": "${SHA256}",
  "version": "0.1.0",
  "archive": "latest.tar.zst",
  "sha256_file": "latest.sha256",
  "download_url": "https://github.com/naftalimurgor/bitgesell-snapshots/releases/latest/download/latest.tar.zst"
}
EOF

########################################
# Summary
########################################

echo
echo "========================================"
echo "Snapshot created successfully"
echo "========================================"
echo
echo "Archive : $OUTPUT_DIR/latest.tar.zst"
echo "Checksum: $OUTPUT_DIR/latest.sha256"
echo "Metadata: $OUTPUT_DIR/snapshot.json"
echo