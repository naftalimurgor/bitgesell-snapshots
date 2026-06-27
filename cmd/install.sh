REPO="naftalimurgor/bitgesell-snapshot"

BASE_URL="https://github.com/${REPO}/releases/latest/download"

SNAPSHOT_URL="${BASE_URL}/latest.tar.zst"
CHECKSUM_URL="${BASE_URL}/latest.sha256"

INSTALL_DIR="${HOME}/.BGL"

#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Configuration
########################################

REPO="naftalimurgor/bitgesell-snapshot"

BASE_URL="https://github.com/${REPO}/releases/latest/download"

SNAPSHOT_URL="${BASE_URL}/latest.tar.zst"
CHECKSUM_URL="${BASE_URL}/latest.sha256"

INSTALL_DIR="${HOME}/.BGL"

########################################
# Colors
########################################

BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"

########################################
# Logging
########################################

log() {
    printf "${BLUE}[INFO]${NC} %s\n" "$*"
}

success() {
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

require() {
    command -v "$1" >/dev/null 2>&1 \
        || die "$1 is required but not installed."
}

########################################

check_dependencies() {

    log "Checking dependencies..."

    require curl
    require tar
    require zstd
    require sha256sum
    require mktemp

    success "Dependencies OK."
}

########################################

prepare_workspace() {

    TMP_DIR=$(mktemp -d)

    trap 'rm -rf "$TMP_DIR"' EXIT

    success "Workspace created."
}

########################################

download_snapshot() {

    log "Downloading snapshot..."

    curl -L \
        --progress-bar \
        -o "${TMP_DIR}/latest.tar.zst" \
        "${SNAPSHOT_URL}"

    success "Snapshot downloaded."

    log "Downloading checksum..."

    curl -L \
        -o "${TMP_DIR}/latest.sha256" \
        "${CHECKSUM_URL}"

    success "Checksum downloaded."
}

########################################

verify_snapshot() {

    log "Verifying snapshot..."

    (
        cd "$TMP_DIR"

        sha256sum -c latest.sha256
    )

    success "Checksum verified."
}

########################################

backup_existing() {

    if [[ -d "$INSTALL_DIR" ]]; then

        BACKUP="${HOME}/.BGL.backup.$(date +%Y%m%d-%H%M%S)"

        log "Backing up existing installation..."

        mv "$INSTALL_DIR" "$BACKUP"

        success "Backup created."

        echo "Backup:"
        echo "  $BACKUP"
        echo

    fi
}

########################################

extract_snapshot() {

    log "Extracting snapshot..."

    tar \
        --zstd \
        -xf "${TMP_DIR}/latest.tar.zst" \
        -C "$HOME"

    success "Snapshot extracted."
}

########################################

finish() {

cat <<EOF

========================================

Bitgesell snapshot installed successfully.

Location:

  ${INSTALL_DIR}

Next steps:

1. Start your Bitgesell node

   bitgeselld

2. Allow it to sync the remaining blocks.

Happy syncing!

========================================

EOF

}

########################################

main() {

cat <<EOF

========================================
 Bitgesell Snapshot Installer
========================================

EOF

    check_dependencies

    prepare_workspace

    download_snapshot

    verify_snapshot

    backup_existing

    extract_snapshot

    finish
}

main