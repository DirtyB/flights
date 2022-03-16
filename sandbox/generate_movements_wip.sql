WITH days AS (
    SELECT ('01.01.2020'::date + interval '1' day * i)::date flight_date
    FROM generate_series(0, 90) i
),
     days_of_week AS (
         SELECT *, extract(isodow from days.flight_date)::int dow
         from days
     ),
     flights AS (
         SELECT *,
                random() delay_factor1,
                random() delay_factor2,
                random() delay_factor3
         from days_of_week dow
                  JOIN flight_schedule sch ON (substr(sch.schedule, dow.dow, 1) <> '-' and random() < 0.95)
     ),
     flights_with_delay AS (
         SELECT *,
                CASE
                    WHEN delay_factor1 >= 0.1 AND delay_factor1 < 0.2 THEN floor(delay_factor2 * 46) + 15
                    WHEN delay_factor1 >= 0.2 AND delay_factor1 < 0.5 THEN floor(delay_factor2 * 7) + 17
                    WHEN delay_factor1 >= 0.5 AND delay_factor1 < 0.55 THEN floor(delay_factor2 * 7) - 23
                    ELSE 0
                    END as dpt_delay,
                CASE
                    WHEN delay_factor1 < 0.2 THEN floor(delay_factor2 * 46) + 15
                    WHEN delay_factor1 >= 0.5 AND delay_factor1 < 0.55 THEN floor(delay_factor3 * 7) - 23
                    ELSE 0
                    END as dst_delay
         from flights
     ),
     actual_fligts AS (
         select *,
                dpt_time_utc + INTERVAL '1' minute * dpt_delay as dpt_actual_time_utc,
                dst_time_utc + INTERVAL '1' minute * dst_delay as dst_actual_time_utc
         from flights_with_delay
     )
INSERT
INTO flight_movement(flight_schedule_id, movement_type, date, time_utc)
SELECT * FROM
(SELECT id                         as flight_schedule_id,
       'departure'::movement_type as movement_type,
       flight_date                as date,
       dpt_actual_time_utc        as time_utc
FROM actual_fligts
UNION ALL
SELECT id                       as flight_schedule_id,
       'arrival'::movement_type as movement_type,
       CASE
           WHEN dst_actual_time_utc <= dpt_actual_time_utc THEN flight_date + INTERVAL '1' day
           ELSE flight_date
           END                  as date,
       dst_actual_time_utc      as time_utc
FROM actual_fligts) movements
ORDER BY date, time_utc;