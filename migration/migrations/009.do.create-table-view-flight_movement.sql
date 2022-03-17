create table flight
(
    id                        uuid default gen_random_uuid() not null
        constraint flight_pk
            primary key,
    flight_schedule_id        uuid                           not null
        constraint flight_flight_schedule_id_fk
            references flight_schedule,
    date                      date                           not null,
    planned_dpt_timestamp_utc timestamp                      not null,
    planned_dst_timestamp_utc timestamp                      not null
);

alter table flight
    add constraint flight_flight_schedule_id_date_uk
        unique (flight_schedule_id, date);

CREATE TYPE movement_type AS ENUM ('departure', 'arrival');

create table flight_movement
(
    id            uuid default gen_random_uuid() not null
        constraint flight_movement_pk
            primary key,
    flight_id     uuid                           not null
        constraint flight_movement_flight_id_fk
            references flight,
    movement_type movement_type                  not null,
    timestamp_utc timestamp not null
);

create view view_flight_movement(flight_number, movement_type, date, time_utc) as
SELECT fs.flight_number,
       fm.movement_type,
       fm.timestamp_utc::date as date,
       fm.timestamp_utc::time as time
FROM flight_movement fm
         JOIN flight f ON f.id = fm.flight_id
         JOIN flight_schedule fs ON fs.id = f.flight_schedule_id;


