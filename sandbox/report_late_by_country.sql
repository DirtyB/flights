SELECT country.country_name destination_country,
       planned,
       completed,
       planned - completed                             cancelled,
       late_delayed,
       late_not_delayed,
       round(1.0 * (planned - completed) / planned, 2) cancelled_rate,
       round(1.0 * late_delayed / completed, 2)        late_delayed_rate,
       round(1.0 * late_not_delayed / completed, 2)    late_not_delayed_rate

FROM (
         SELECT country_id,
                count(*)                                             as planned,
                count(*) filter ( where is_completed )               as completed,
                count(*) filter ( where is_late and not is_delayed ) as late_not_delayed,
                count(*) filter ( where is_late and is_delayed )     as late_delayed

         FROM (
                  SELECT *,
                         (dpt_ts_actual > dpt_ts_planned)                         as is_delayed,
                         (dst_ts_actual >= dst_ts_planned + interval '15' minute) as is_late
                  FROM (
                           SELECT flight.*,
                                  dst_a.country_id,
                                  (arrival.id IS NOT NULL)         as is_completed,
                                  flight.planned_dpt_timestamp_utc as dpt_ts_planned,
                                  departure.timestamp_utc          as dpt_ts_actual,
                                  flight.planned_dst_timestamp_utc as dst_ts_planned,
                                  arrival.timestamp_utc            as dst_ts_actual

                           FROM flight
                                    JOIN flight_schedule fs ON flight.flight_schedule_id = fs.id
                                    JOIN airport dst_a ON fs.dst_airport_id = dst_a.id
                                    LEFT JOIN (SELECT * FROM flight_movement WHERE movement_type = 'departure') departure
                                              on flight.id = departure.flight_id
                                    LEFT JOIN (SELECT * FROM flight_movement WHERE movement_type = 'arrival') arrival
                                              on flight.id = arrival.flight_id
                       ) f1

             ) f

        GROUP BY country_id
     ) c
JOIN country on c.country_id = country.id
ORDER BY destination_country
;