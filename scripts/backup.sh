#!/bin/sh
set -xe

usage() {
  echo "Usage: $0 <recipes_root_dir> [backup_dir]"
  exit 1
}

# Check if RECIPES_DIR is provided
if [ -z "$1" ]; then
  usage
fi

timestamp=$(date +%Y%m%d_%H%M%S)
RECIPES_DIR="$1"
BACKUP_DIR="${2:-$(pwd)}"
BACKUP_TAR_FILE="recipes_backup_${timestamp}.tgz"
RECIPES_DB_DUMP_FILE="recipes.sql"

# Load environment variables from .env file
if [ -f "$RECIPES_DIR/.env" ]; then
  . "$RECIPES_DIR/.env"
else
  echo "Error: Missing .env file in $RECIPES_DIR"
  exit 1
fi

# Check if required environment variables are set
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
  echo "Error: PostgreSQL environment variables are not set in .env file"
  exit 1
fi

compose="docker-compose -f $RECIPES_DIR/docker-compose.yml"

$compose start db
$compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/pg_dump -h db --no-owner -U $POSTGRES_USER $POSTGRES_DB --no-password > "${BACKUP_DIR}/${RECIPES_DB_DUMP_FILE}"
docker run --rm  -v "${BACKUP_DIR}:/backup-dir" -v "${BACKUP_DIR}/${RECIPES_DB_DUMP_FILE}:/tmp/recipes.sql:ro" -v "recipes_live_view_photos:/tmp/photos:ro" ubuntu:24.04 tar czf "/backup-dir/${BACKUP_TAR_FILE}" -C /tmp recipes.sql ./photos

echo "${BACKUP_DIR}/${BACKUP_TAR_FILE}"
