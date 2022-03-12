create table raw_airport
(
    code        varchar(10),
    name        varchar(500),
    country     varchar(500),
    lat         varchar(500),
    lon         varchar(500)
);

comment on table raw_airport is 'raw import airport data';
