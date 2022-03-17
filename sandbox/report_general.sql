SELECT round(1.0 * completed / planned, 2)              completion_rate,
       round(1.0 * late / completed, 2)                 late_rate,
       round(1.0 * delayed_and_late / late, 2)          delayed_among_late_rate,
       round(1.0 * delayed_and_not_late / completed, 2) delayed_not_late_rate,
       round(1.0 * early_arrival / completed, 2)        early_arrival_rate,
       *

FROM (
         SELECT count(*)                                                                      as planned,
                count(*) filter ( where is_completed )                                        as completed,
                count(*) filter ( where is_late )                                             as late,
                count(*) filter ( where is_late and is_delayed )                              as delayed_and_late,
                count(*) filter ( where is_delayed and not is_late )                          as delayed_and_not_late,
                count(*) filter ( where is_early_departure )                                  as early_departure,
                count(*) filter ( where is_early_arrival )                                    as early_arrival,
                min(dpt_ts_actual - dpt_ts_planned) filter (where is_delayed)                 as min_delay,
                max(dpt_ts_actual - dpt_ts_planned) filter (where is_delayed)                 as max_delay,
                min(dst_ts_actual - dst_ts_planned) filter (where is_late)                    as min_late,
                max(dst_ts_actual - dst_ts_planned) filter (where is_late)                    as max_late,
                min(dpt_ts_actual - dpt_ts_planned) filter (where is_delayed and not is_late) as min_delay_not_late,
                max(dpt_ts_actual - dpt_ts_planned) filter (where is_delayed and not is_late) as max_delay_not_late,
                min(dpt_ts_planned - dpt_ts_actual) filter (where is_early_departure)         as min_early_departure,
                max(dpt_ts_planned - dpt_ts_actual) filter (where is_early_departure)         as max_early_departure,
                min(dst_ts_planned - dst_ts_actual) filter (where is_early_arrival)           as min_early_arrival,
                max(dst_ts_planned - dst_ts_actual) filter (where is_early_arrival)           as max_early_arrival
         FROM (
                  SELECT *,
                         (dpt_ts_actual > dpt_ts_planned)                         as is_delayed,
                         (dst_ts_actual >= dst_ts_planned + interval '15' minute) as is_late,
                         (dpt_ts_actual < dpt_ts_planned)                         as is_early_departure,
                         (dst_ts_actual < dst_ts_planned)                         as is_early_arrival
                  FROM (
                           SELECT flight.*,
                                  (arrival.id IS NOT NULL)         as is_completed,
                                  flight.planned_dpt_timestamp_utc as dpt_ts_planned,
                                  departure.timestamp_utc          as dpt_ts_actual,
                                  flight.planned_dst_timestamp_utc as dst_ts_planned,
                                  arrival.timestamp_utc            as dst_ts_actual

                           FROM flight
                                    JOIN flight_schedule fs ON flight.flight_schedule_id = fs.id
                                    LEFT JOIN (SELECT * FROM flight_movement WHERE movement_type = 'departure') departure
                                              on flight.id = departure.flight_id
                                    LEFT JOIN (SELECT * FROM flight_movement WHERE movement_type = 'arrival') arrival
                                              on flight.id = arrival.flight_id
                       ) f1
              ) f
     ) c;