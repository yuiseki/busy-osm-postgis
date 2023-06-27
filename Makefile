include .env

pbf = tmp/osm/$(REGION)-latest.osm.pbf

targets = \
	$(pbf) \
	docker-pull \
	docker-build

all: $(targets)

# Pull docker image if not exists
.PHONY: docker-pull
docker-pull:
	docker image inspect postgis/postgis:15-3.3 > /dev/null || docker pull postgis/postgis:15-3.3
	docker image inspect dpage/pgadmin4:6.18 > /dev/null || docker pull dpage/pgadmin4:6.18
	docker image inspect geotekne/imposm-worker:1.0.0 > /dev/null || docker pull geotekne/imposm-worker:1.0.0

# Build docker image if not exists
.PHONY: docker-build
docker-build:
	docker image inspect yuiseki/busy-osm-postgis:latest > /dev/null || docker build . -t yuiseki/busy-osm-postgis:latest

# Push docker image to docker hub
# NOTE: require `docker login`
.PHONY: docker-push
docker-push:
	docker push yuiseki/busy-osm-postgis:latest

# Download OpenStreetMap data as Protocolbuffer Binary format file
$(pbf):
	mkdir -p $(@D)
	curl \
		--continue-at - \
		--output $(pbf) \
		https://download.geofabrik.de/$(REGION)-latest.osm.pbf

.PHONY: import-imposm
import-imposm:
	docker run \
		-i \
		--rm \
		--mount type=bind,source=$(CURDIR)/tmp/osm/europe,target=/pbfs \
		--mount type=bind,source=$(CURDIR)/docker/imposm/mapping.yml,target=/scripts/mapping.yml \
		--net=busy-osm-postgis \
		--entrypoint="" \
		geotekne/imposm-worker:1.0.0 \
			/scripts/import-pg.sh \
				-i /pbfs \
				-c busy-osm-postgis_postgis \
				-v 15 \
				-p 5432 \
				-u postgres \
				-w postgres \
				-d imposm

.PHONY: import-osm2pgsql
import-osm2pgsql:
	docker run \
		-i \
		--rm \
		--mount type=bind,source=$(CURDIR)/tmp,target=/tmp \
		--net=busy-osm-postgis \
		yuiseki/busy-osm-postgis \
			osm2pgsql \
				--create \
				--slim \
				--hstore \
				--cache 2000 \
				--number-processes 2 \
				--database osm2pgsql \
				--username postgres \
				--host postgis \
				--port 5432 \
				/$(pbf)

.PHONY: setup-osmosis
setup-osmosis:
	docker run \
		-i \
		--rm \
		--mount type=bind,source=$(CURDIR)/tmp,target=/tmp \
		--net=busy-osm-postgis \
		yuiseki/busy-osm-postgis \
			psql -h postgis -d osmosis -U postgres -f /app/script/pgsnapshot_schema_0.6.sql && \
			psql -h postgis -d osmosis -U postgres -f /app/script/pgsnapshot_schema_0.6_action.sql && \
			psql -h postgis -d osmosis -U postgres -f /app/script/pgsnapshot_schema_0.6_bbox.sql && \
			psql -h postgis -d osmosis -U postgres -f /app/script/pgsnapshot_schema_0.6_linestring.sql

.PHONY: import-osmosis
import-osmosis:
	docker run \
		-i \
		--rm \
		--mount type=bind,source=$(CURDIR)/tmp,target=/tmp \
		--net=busy-osm-postgis \
		yuiseki/busy-osm-postgis \
			osmosis \
				--read-pbf file=/$(pbf) \
				--log-progress \
				--write-pgsql host="postgis" user="postgres" password="postgres" database="osmosis"

.PHONY: export-osmosis
export-osmosis:
	docker run \
		-i \
		--rm \
		--mount type=bind,source=$(CURDIR)/tmp,target=/tmp \
		--net=busy-osm-postgis \
		yuiseki/busy-osm-postgis \
			osmosis \
				--read-pgsql host="postgis" user="postgres" password="postgres" database="osmosis" \
				--dataset-dump \
				--write-pbf file=/tmp/region.osmosis.pbf
