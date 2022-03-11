CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION IF NOT EXISTS postgis;

-- create table raw_ariport
-- (
--     id          uuid default gen_random_uuid() not null
--         constraint raw_ariport_pk
--             primary key,
--     code        varchar(10),
--     name        varchar(500),
--     country     varchar(500),
--     coordinates geography(Point, 4326)
-- );

create table raw_ariport
(
    code        varchar(10),
    name        varchar(500),
    country     varchar(500),
    lat         varchar(500),
    lon         varchar(500)
);

alter table raw_ariport
    owner to flights;

-- create index raw_ariport_coordinates_gix
--     on raw_ariport using gist (coordinates);
