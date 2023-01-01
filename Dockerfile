FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=en_US.UTF-8

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    osm2pgsql \
    osmosis \
    osmium-tool \
    postgresql-client \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  unzip \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /app
RUN wget https://github.com/openstreetmap/osmosis/releases/download/0.48.3/osmosis-0.48.3.zip && \
  unzip osmosis-0.48.3.zip

WORKDIR /tmp

RUN npm i -g http-server
RUN git clone --depth 1 https://github.com/unvt/charites &&\
  cd charites; npm ci; npm run build; npm install -g .

WORKDIR /app

CMD ["/bin/bash"]
