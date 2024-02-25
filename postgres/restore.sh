#!/bin/sh
set -xe

usage() {
  echo "Usage: $0 <backup_archive>"
  exit 1
}

# Check if BACKUP_ARCHIVE is provided
if [ -z "$1" ]; then
  usage
fi

BACKUP_ARCHIVE="${1}"
BACKUP_DIR=$(mktemp -d)

alias compose="docker-compose -f docker-compose.yml"
. ./.env
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
  echo "Make sure to set postgres environment variables in .env before running this script!"
  exit 1
fi

tar xzfv $BACKUP_ARCHIVE -C $BACKUP_DIR
compose up -d 
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/dropdb -h db -U $POSTGRES_USER $POSTGRES_DB
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/createdb -h db -U $POSTGRES_USER $POSTGRES_DB
compose run --rm -T -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/psql -h db -U $POSTGRES_USER $POSTGRES_DB < $BACKUP_DIR/recipes_db_dump_new.sql
compose start db

rm -rf $BACKUP_DIR
