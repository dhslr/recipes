#!/bin/sh
set -e

usage() {
  echo "Usage: $0 <recipes_root_dir> [backup_dir]"
  exit 1
}

# Check if RECIPES_DIR is provided
if [ -z "$1" ]; then
  usage
fi

RECIPES_DIR="$1"
BACKUP_DIR="${2:-$(pwd)}"
RECIPES_DUMP_FILE="recipes_db_dump_new.sql"
BACKUP_TAR_FILE="backup.tgz"

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
$compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/pg_dump -h db --no-owner -U $POSTGRES_USER $POSTGRES_DB --no-password > "${BACKUP_DIR}/${RECIPES_DUMP_FILE}"
$compose run --rm --entrypoint "" -v "${BACKUP_DIR}:/backup" app tar czpf "/backup/${BACKUP_TAR_FILE}" "/app/lib/recipes-0.2.0/priv/static/photos" -C /backup $RECIPES_DUMP_FILE 
rm "${BACKUP_DIR}/${RECIPES_DUMP_FILE}"

echo "Backup ${BACKUP_DIR}/${BACKUP_TAR_FILE} completed successfully!"
