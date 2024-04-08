
docker-compose run --rm -v ~/projects/recipes/bla/tmp:/backup postgres psql -h postgres -U postgres -d recipes_backend_dev -f /backup/recipes_db.sql
