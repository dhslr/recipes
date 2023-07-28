#!/bin/sh
set -xe
RECIPES_DIR=/home/daniel/git/recipes_live_view
BACKUP_DIR=$RECIPES_DIR/backup 
alias compose="docker-compose -f $RECIPES_DIR/docker-compose.yml"
. $RECIPES_DIR/.env
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
  echo "Make sure to set postgres environment variables in .env before running this script!"
  exit 1
fi

compose start db
compose stop app
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/dropdb -h db -U $POSTGRES_USER $POSTGRES_DB
compose run --rm -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/createdb -h db -U $POSTGRES_USER $POSTGRES_DB
compose run --rm -T -e PGPASSWORD="${POSTGRES_PASSWORD}" db /usr/bin/psql -h db -U $POSTGRES_USER $POSTGRES_DB < $BACKUP_DIR/recipes_db_dump_new.sql
compose run --rm -v $BACKUP_DIR:/backup -u root app tar xzpf /backup/photos_new.tgz -C /
compose start app
