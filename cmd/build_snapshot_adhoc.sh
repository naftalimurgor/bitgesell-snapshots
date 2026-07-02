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

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Creating snapshot..."

########################################
# Copy blockchain
########################################

mkdir -p "$TMP_DIR/.BGL"

rsync -a \
    --exclude="BGL.conf" \
    "$SOURCE_DIR/" \
    "$TMP_DIR/.BGL/"

########################################
# Archive
########################################

tar \
    -cf "$OUTPUT_DIR/latest.tar" \
    -C "$TMP_DIR" \
    .BGL

########################################
# Compress
########################################

zstd -19 \
    --rm \
    "$OUTPUT_DIR/latest.tar"

mv \
    "$OUTPUT_DIR/latest.tar.zst" \
    "$OUTPUT_DIR/latest.tar.zst"

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
  "download_url": "https://github.com/naftalimurgor/bitgesell-snapshots/releases/latest.tar.zst"
}
EOF

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