create table flight
(
    id                 uuid default gen_random_uuid() not null
        constraint flight_pk
            primary key,
    flight_schedule_id uuid                           not null
        constraint flight_flight_schedule_id_fk
            references flight_schedule,
    date               date                           not null
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
    date          date                           not null,
    time_utc      time with time zone            not null
);

create view view_flight_movement(flight_number, movement_type, date, time_utc) as
SELECT fs.flight_number,
       fm.movement_type,
       fm.date::text                   AS date,
       substr(fm.time_utc::text, 1, 5) AS time_utc
FROM flight_movement fm
         JOIN flight f ON f.id = fm.flight_id
         JOIN flight_schedule fs ON fs.id = f.flight_schedule_id;


