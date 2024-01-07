#!/bin/sh
set -xe
RECIPES_DIR=/home/daniel/git/recipes_live_view
BACKUP_DIR=$RECIPES_DIR/backup
alias compose="docker-compose -f $RECIPES_DIR/docker-compose.yml"
. $RECIPES_DIR/.env
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
  echo "Make sure to set postgres environment variables in before running this script!"
  exit 1
fi

mkdir -p $BACKUP_DIR
compose start db
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/pg_dump -h db --no-owner -U $POSTGRES_USER $POSTGRES_DB --no-password > $BACKUP_DIR/recipes_db_dump_new.sql
compose run --rm --entrypoint "" -v $BACKUP_DIR:/backup -u root app tar czpf /backup/photos_new.tgz /app/lib/recipes-0.2.0/priv/static/photos
