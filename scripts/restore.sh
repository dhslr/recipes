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
BACKUP_ARCHIVE="${2:-$1/backup.tgz}"
BACKUP_DIR=$(mktemp -d)

alias compose="docker-compose -f $RECIPES_DIR/docker-compose.yml"
. $RECIPES_DIR/.env
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
  echo "Make sure to set postgres environment variables in .env before running this script!"
  exit 1
fi

tar xzfv $BACKUP_ARCHIVE -C $BACKUP_DIR
compose start db
compose stop app
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/dropdb -h db -U $POSTGRES_USER $POSTGRES_DB
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/createdb -h db -U $POSTGRES_USER $POSTGRES_DB
compose run --rm -T -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/psql -h db -U $POSTGRES_USER $POSTGRES_DB < $BACKUP_DIR/recipes_db_dump_new.sql
compose start app
docker cp $BACKUP_DIR/app recipes_app:/app

rm -rf $BACKUP_DIR
