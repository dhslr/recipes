#!/bin/sh
set -xe

usage() {
  echo "Usage: $0 <recipes_root_dir> [backup_archive]"
  exit 1
}

# Check if RECIPES_DIR is provided
if [ -z "$1" ]; then
  usage
fi

RECIPES_DIR="$1"
BACKUP_DIR=$(mktemp -d)
BACKUP_TAR_FILE="${2:-$1/backup.tgz}"
RECIPES_DB_DUMP_FILE="recipes.sql"

if command -v docker-compose >/dev/null 2>&1; then
  alias compose="docker-compose -f $RECIPES_DIR/docker-compose.yml"
else
  alias compose="docker compose -f $RECIPES_DIR/docker-compose.yml"
fi

. $RECIPES_DIR/.env
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
  echo "Make sure to set postgres environment variables in .env before running this script!"
  exit 1
fi

tar xzfv $BACKUP_TAR_FILE -C $BACKUP_DIR
compose start db
compose stop app
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db sh -c "dropdb -h db -U $POSTGRES_USER $POSTGRES_DB && createdb -h db -U $POSTGRES_USER $POSTGRES_DB"
compose run --rm -T -e PGPASSWORD="${POSTGRES_PASSWORD}" db psql -h db -U $POSTGRES_USER $POSTGRES_DB < "${BACKUP_DIR}/${RECIPES_DB_DUMP_FILE}"
docker run --rm  -v "${BACKUP_TAR_FILE}:/tmp/backup.tgz" -v "recipes_live_view_photos:/tmp/photos" ubuntu:24.04 sh -c "rm -rf /tmp/photos/{*,.*}; tar xzfv /tmp/backup.tgz -C /tmp"
compose restart

rm -rf $BACKUP_DIR
