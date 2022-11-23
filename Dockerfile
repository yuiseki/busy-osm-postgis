FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=en_US.UTF-8

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    osm2pgsql \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

RUN osm2pgsql --help
