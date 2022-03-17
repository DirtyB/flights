WITH flights AS (
    SELECT id as    flight_id,
           date,
           flight_schedule_id,
           planned_dpt_timestamp_utc,
           planned_dst_timestamp_utc,
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
                planned_dpt_timestamp_utc + interval '1' minute * dpt_delay dpt_actual_timestamp_utc,
                planned_dst_timestamp_utc + interval '1' minute * dst_delay dst_actual_timestamp_utc
         from flights_with_delay
     )
INSERT
INTO flight_movement(flight_id, movement_type, timestamp_utc)
SELECT *
FROM (SELECT flight_id,
             'departure'::movement_type as movement_type,
             dpt_actual_timestamp_utc   as timestamp_utc
      FROM actual_fligts
      UNION ALL
      SELECT flight_id,
             'arrival'::movement_type as movement_type,
             dst_actual_timestamp_utc as timestamp_utc
      FROM actual_fligts) movements
ORDER BY timestamp_utc;