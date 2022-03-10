CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION IF NOT EXISTS postgis;

create table ariport
(
    id          uuid default gen_random_uuid() not null
        constraint ariport_pk
            primary key,
    code        varchar(10),
    name        varchar(500),
    country     varchar(500),
    coordinates geography(Point, 4326)
);

alter table ariport
    owner to flights;

create index ariport_coordinates_gix
    on ariport using gist (coordinates);
