#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Configuration
########################################

SOURCE_DIR="${HOME}/.BGL"
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/snapshots"

DATE="$(date +"%d-%m-%y")"

ARCHIVE="snapshot-${DATE}.tar"
COMPRESSED="${ARCHIVE}.zst"

########################################
# Logging
########################################

BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"

log() {
    printf "${BLUE}[INFO]${NC} %s\n" "$*"
}

ok() {
    printf "${GREEN}[ OK ]${NC} %s\n" "$*"
}

warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$*"
}

die() {
    printf "${RED}[FAIL]${NC} %s\n" "$*"
    exit 1
}

########################################
# Dependency Check
########################################

require() {
    command -v "$1" >/dev/null 2>&1 \
        || die "$1 is not installed."
}

check_dependencies() {

    log "Checking dependencies..."

    require rsync
    require tar
    require zstd
    require sha256sum

    ok "Dependencies OK."
}

########################################
# Validate source
########################################

check_source() {

    [[ -d "$SOURCE_DIR" ]] \
        || die "Bitgesell directory not found: $SOURCE_DIR"

    [[ -d "$SOURCE_DIR/blocks" ]] \
        || die "blocks directory missing."

    [[ -d "$SOURCE_DIR/chainstate" ]] \
        || die "chainstate directory missing."

    ok "Source directory verified."
}

########################################
# Workspace
########################################

prepare_workspace() {

    mkdir -p "$OUTPUT_DIR"

    TMP_DIR=$(mktemp -d)

    trap 'rm -rf "$TMP_DIR"' EXIT

    mkdir -p "$TMP_DIR/.BGL"

    ok "Workspace ready."
}

########################################
# Copy blockchain
########################################

copy_blockchain() {

    log "Copying blockchain..."

    rsync -a \
        "$SOURCE_DIR/blocks" \
        "$TMP_DIR/.BGL/"

    rsync -a \
        "$SOURCE_DIR/chainstate" \
        "$TMP_DIR/.BGL/"

    if [[ -d "$SOURCE_DIR/indexes" ]]; then
        rsync -a \
            "$SOURCE_DIR/indexes" \
            "$TMP_DIR/.BGL/"
    fi

    if [[ -f "$SOURCE_DIR/peers.dat" ]]; then
        cp "$SOURCE_DIR/peers.dat" \
           "$TMP_DIR/.BGL/"
    fi

    ok "Blockchain copied."
}

########################################
# Create archive
########################################

create_archive() {

    log "Creating archive..."

    tar \
        -cf "${OUTPUT_DIR}/${ARCHIVE}" \
        -C "$TMP_DIR" \
        .BGL

    ok "Archive created."
}

########################################
# Compress
########################################

compress_archive() {

    log "Compressing..."

    zstd -19 \
        --rm \
        "${OUTPUT_DIR}/${ARCHIVE}"

    ok "Compression complete."
}

########################################
# SHA256
########################################

generate_checksum() {

    log "Generating checksum..."

    (
        cd "$OUTPUT_DIR"

        sha256sum "$COMPRESSED" > "${COMPRESSED}.sha256"
    )

    ok "Checksum generated."
}

########################################
# Latest copies
########################################

update_latest() {

    log "Updating latest snapshot..."

    cp "${OUTPUT_DIR}/${COMPRESSED}" \
       "${OUTPUT_DIR}/latest.tar.zst"

    cp "${OUTPUT_DIR}/${COMPRESSED}.sha256" \
       "${OUTPUT_DIR}/latest.sha256"

    ok "Latest snapshot updated."
}

########################################
# Summary
########################################

summary() {

    SIZE=$(du -h "${OUTPUT_DIR}/${COMPRESSED}" | cut -f1)

    cat <<EOF

========================================

Snapshot created successfully.

File:
  ${OUTPUT_DIR}/${COMPRESSED}

Checksum:
  ${OUTPUT_DIR}/${COMPRESSED}.sha256

Size:
  ${SIZE}

Ready for upload to GitHub Releases.

========================================

EOF
}

########################################

main() {

cat <<EOF

========================================
 Bitgesell Snapshot Builder
========================================

EOF

    check_dependencies
    check_source
    prepare_workspace
    copy_blockchain
    create_archive
    compress_archive
    generate_checksum
    update_latest
    summary
}

main