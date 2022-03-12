CREATE EXTENSION IF NOT EXISTS postgis;

create table if not exists airport
(
    id          uuid default gen_random_uuid() not null
        constraint airport_pk
            primary key,
    code        varchar(10)                    not null,
    name        varchar(500)                   not null,
    country_id  uuid                           not null
        constraint airport_country_id_fk
            references country,
    coordinates geography(Point, 4326)
);

comment on table airport is 'airports';

create unique index if not exists airport_code_uindex
    on airport (code);

create index if not exists airport_coordinates_gix
    on airport using gist (coordinates);

