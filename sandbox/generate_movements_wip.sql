WITH flights AS (
    SELECT id as    flight_id,
           date,
           flight_schedule_id,
           random() delay_factor1,
           random() delay_factor2,
           random() delay_factor3
    from flight
    where random() < 0.95
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
                  JOIN flight_schedule fs on fs.id = flights_with_delay.flight_schedule_id
     )
INSERT
INTO flight_movement(flight_id, movement_type, date, time_utc)
SELECT *
FROM (SELECT flight_id,
             'departure'::movement_type as movement_type,
             date,
             dpt_actual_time_utc        as time_utc
      FROM actual_fligts
      UNION ALL
      SELECT flight_id,
             'arrival'::movement_type as movement_type,
             CASE
                 WHEN dst_actual_time_utc <= dpt_actual_time_utc THEN date + INTERVAL '1' day
                 ELSE date
                 END                  as date,
             dst_actual_time_utc      as time_utc
FROM actual_fligts) movements
ORDER BY date, time_utc;