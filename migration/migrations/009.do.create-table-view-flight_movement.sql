CREATE TYPE movement_type AS ENUM ('departure', 'arrival');

create table flight_movement
(
    id                 uuid default gen_random_uuid() not null
        constraint flight_movement_pk
            primary key,
    flight_schedule_id uuid                           not null
        constraint flight_movement_flight_schedule_id_fk
            references flight_schedule,
    movement_type      movement_type                  not null,
    date               date                           not null,
    time_utc           time with time zone            not null
);

create view view_flight_movement(flight_number, movement_type, date, time_utc) as
SELECT fs.flight_number,
       fm.movement_type,
       fm.date::text                   AS date,
       substr(fm.time_utc::text, 1, 5) AS time_utc
FROM flight_movement fm
         JOIN flight_schedule fs ON fs.id = fm.flight_schedule_id;


