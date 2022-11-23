include .env

pbf = tmp/osm/$(REGION)-latest.osm.pbf

targets = \
	$(pbf)

all: $(targets)

# Pull  docker image if not exists
.PHONY: docker-pull
docker-pull:
	docker image inspect yuiseki/busy-osm-postgis:latest > /dev/null || docker pull yuiseki/busy-osm-postgis:latest

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

.PHONY: import-osm
import-osm:
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
				--database osm \
				--username postgres \
				--host postgis \
				--port 5432 \
				$(pbf)
