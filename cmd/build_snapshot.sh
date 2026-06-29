########################################
# Configuration
########################################

SOURCE_DIR="${HOME}/.BGL"
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/snapshots"

DATE="$(date +"%d-%m-%y")"

ARCHIVE="snapshot-${DATE}.tar"
COMPRESSED="${ARCHIVE}.zst"