#!/bin/bash -e
export PGPASSWORD=transitclock
export PGUSERNAME=postgres

docker rm --force transitclock-db transitclock-server-instance

docker rmi --force transitclock-server

# Builds image from Dockerfile
docker build --no-cache -t transitclock-server .

# Initiates the database container
docker run \
  --name transitclock-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD="${PGPASSWORD}" \
  -e POSTGRES_USER="${PGUSERNAME}" \
  -d \
  postgres:9.6.12 postgres -N 10000

# Check that the database is up
docker run \
  --name transitclock-server-instance \
  --rm \
  --link transitclock-db:postgres \
  -e PGPASSWORD="${PGPASSWORD}" \
  -e PGUSERNAME="${PGUSERNAME}" \
  transitclock-server \
  check_db_up.sh

# Sets up the database and necessary stuff
docker run \
  --name transitclock-server-instance \
  --rm \
  --link transitclock-db:postgres \
  -e PGPASSWORD="${PGPASSWORD}" \
  -e PGUSERNAME="${PGUSERNAME}" \
  transitclock-server \
  agency-looper.runtime.tables.sh

# Sets up the database and necessary stuff
docker run \
  --name transitclock-server-instance \
  --rm \
  --link transitclock-db:postgres \
  -e PGPASSWORD="${PGPASSWORD}" \
  -e PGUSERNAME="${PGUSERNAME}" \
  transitclock-server \
  agency-looper.runtime.gtfs.sh

# Starts TransitClock cores
docker run \
  --name transitclock-server-instance \
  --rm \
  --link transitclock-db:postgres \
  -e PGPASSWORD="${PGPASSWORD}" \
  -e PGUSERNAME="${PGUSERNAME}" \
  -p 3020:8080 \
  transitclock-server \
  agency-looper.start.sh
