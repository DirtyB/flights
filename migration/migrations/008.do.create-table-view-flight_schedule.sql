create table flight_schedule
(
    id             uuid default gen_random_uuid() not null
        constraint flight_schedule_pk
            primary key,
    flight_number  varchar(4)                     not null,
    dpt_airport_id uuid                           not null
        constraint flight_schedule_dpt_airport_id_fk
            references airport,
    dst_airport_id uuid                           not null
        constraint flight_schedule_dst_airport_id_fk
            references airport,
    plaintype_id   uuid                           not null
        constraint flight_schedule_planetype_id_fk
            references planetype,
    schedule       varchar(7)                     not null,
    dpt_local_time time without time zone         not null,
    duration       interval                       not null
);

create unique index flight_schedule_flight_number_uindex
    on flight_schedule (flight_number);

create view view_flight_schedule
            (flight_number, dpt_airport_code, dst_airport_code, plane_type, schedule, dpt_time_utc, dst_time_utc) as
SELECT fs.flight_number,
       dpt_a.code  AS                                                                       dpt_airport_code,
       dst_a.code  AS                                                                       dst_airport_code,
       p.type_name AS                                                                       plane_type,
       fs.schedule,
       (('2020-01-01'::date + dpt_local_time)::timestamp at time zone dpt_a.timezone)::time dpt_time_utc,
       (('2020-01-01'::date + dpt_local_time)::timestamp at time zone dpt_a.timezone + duration)::time dst_time_utc
FROM flight_schedule fs
         JOIN airport dpt_a ON dpt_a.id = fs.dpt_airport_id
         JOIN airport dst_a ON dst_a.id = fs.dst_airport_id
         JOIN planetype p ON p.id = fs.plaintype_id;
