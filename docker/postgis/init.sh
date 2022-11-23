#!/bin/bash
set -ex

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL
    CREATE USER osmuser;
    GRANT ALL PRIVILEGES ON DATABASE osm TO osmuser;
EOSQL


# Create btree_gist extensions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION btree_gist" osm

# Create hstore extensions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION hstore" osm
