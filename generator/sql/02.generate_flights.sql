WITH days AS (
    SELECT ('01.01.2020'::date + interval '1' day * i)::date date
    FROM generate_series(0, 90) i
),
     days_of_week AS (
         SELECT *, extract(isodow from days.date)::int dow
         from days
     )
INSERT INTO flight(flight_schedule_id, date, planned_dpt_timestamp_utc, planned_dst_timestamp_utc)
SELECT fs.id as                                                                    flight_schedule_id,
       dow.date,
       ((date + dpt_local_time)::timestamp at time zone dpt_a.timezone)            planned_dpt_timestamp_utc,
       ((date + dpt_local_time)::timestamp at time zone dpt_a.timezone + duration) planned_dst_timestamp_utc
from days_of_week dow
         JOIN flight_schedule fs ON (substr(fs.schedule, dow.dow, 1) <> '-')
         JOIN airport dpt_a on fs.dpt_airport_id = dpt_a.id
