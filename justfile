_default:
  @just --list

up:
  docker compose up -d
  docker compose logs --follow

down:
  docker compose down

sh:
  docker compose exec -it server sh

psql:
  docker compose exec -it postgres psql -U march march
