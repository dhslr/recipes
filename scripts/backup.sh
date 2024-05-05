#!/bin/sh
set -xe

BACKUP_DIR="${1:-$(pwd)}"
timestamp=$(date +%Y%m%d_%H%M%S)
BACKUP_TAR_FILE="recipes_backup_${timestamp}.tgz"

docker run --rm  -v "${BACKUP_DIR}:/backup-dir" -v recipes_live_view_data:/tmp/data:ro -v recipes_live_view_photos:/tmp/photos:ro ubuntu:24.04 tar czfv "/backup-dir/${BACKUP_TAR_FILE}" -C /tmp ./data ./photos

echo "Backup ${BACKUP_DIR}/${BACKUP_TAR_FILE} completed successfully!"
