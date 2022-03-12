create table country
(
    id           uuid
        default gen_random_uuid()
        constraint country_pk
            primary key,
    country_name varchar(500) not null,
    country_code varchar(10)
);

comment on table country is 'countries';