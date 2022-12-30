#!/bin/bash
set -ex

# Create databases
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE osm2pgsql TEMPLATE=template_postgis"
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE osmosis TEMPLATE=template_postgis"
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE imposm TEMPLATE=template_postgis"

# Create btree_gist extensions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION btree_gist" -d osm2pgsql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION btree_gist" -d osmosis
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION btree_gist" -d imposm

# Create hstore extensions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION hstore" -d osm2pgsql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION hstore" -d osmosis
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION hstore" -d imposm
