# busy-osm-postgis

## What is it?

Repository for handling OpenStreetMap data in PostGIS for super busy people.

## How to use it?

If you are looking at this repository, you are probably a very busy person, so immediately execute the following command to get the job done.
(If you are super busy, of course you have already prepared commands such as `docker`, `make` and `curl`.)

```
git clone https://github.com/yuiseki/busy-osm-postgis.git
cd busy-osm-postgis
docker compose up -d
make
make import-imposm
```

- Open http://localhost:5050/
  - Login
    - email: `admin@example.com`
    - pass: `admin`
- Click `Server Group 1`
  - Click `postgis`
    - Click `Databases`
      - Click `imposm`
        - Click `Schemas`
          - Click `public`
            - Click `Tables`
              - Click `osm_buildings`
                - Click `View Data` (or `Alt + Shift + V`)
                  - Scroll horizontally and find column named `way`
                    - Click `View all geometries in this column` button

[![Image from Gyazo](https://i.gyazo.com/4c2f37e93162d23f2ea3e66ab630d969.png)](https://gyazo.com/4c2f37e93162d23f2ea3e66ab630d969)

## How it works

This repos depends on the following softwares:

- PostGIS on PostgreSQL
  - https://postgis.net/
  - Most important software
  - Store OpenStreetMap data as SQL DB
- pgAdmin
  - https://github.com/pgadmin-org/pgadmin4
  - Very useful software
  - Preview the data in PostgreSQL
- osm2pgsql
  - https://github.com/openstreetmap/osm2pgsql
  - Also important software
  - Import OpenStreetMap data into DB
