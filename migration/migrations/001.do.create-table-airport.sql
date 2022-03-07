CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

create table planetype
(
    id        uuid
        constraint planetype_pk
            primary key,
    type_name varchar(10) not null,
    speed     int         not null
);

comment on table planetype is 'types of planes';

insert into planetype (id, type_name, speed)
values (uuid_generate_v4(), 'B733', 430),
       (uuid_generate_v4(), 'PAY2', 230),
       (uuid_generate_v4(), 'C500', 250),
       (uuid_generate_v4(), 'B738', 440),
       (uuid_generate_v4(), 'PA34', 130),
       (uuid_generate_v4(), 'A320', 420);
