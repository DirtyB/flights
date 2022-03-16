WITH days AS (
    SELECT ('01.01.2020'::date + interval '1' day * i)::date date
    FROM generate_series(0, 90) i
),
     days_of_week AS (
         SELECT *, extract(isodow from days.date)::int dow
         from days
     )
INSERT INTO flight(flight_schedule_id, date)
SELECT fs.id as flight_schedule_id, dow.date
from days_of_week dow
         JOIN flight_schedule fs ON (substr(fs.schedule, dow.dow, 1) <> '-')