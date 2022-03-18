SELECT a.code,
       count(*) as count,
       min(fs.dpt_local_time) as first_flight,
       max(fs.dpt_local_time) as last_flight,
       min(next_flight.dpt_local_time - fs.dpt_local_time) shortest_interval
FROM flight_schedule fs
         JOIN airport a on a.id = fs.dpt_airport_id
         LEFT JOIN LATERAL (
    SELECT fs2.dpt_local_time
    FROM flight_schedule fs2
    WHERE fs.dpt_airport_id = fs2.dpt_airport_id
      AND fs.dpt_local_time < fs2.dpt_local_time
    ORDER BY dpt_local_time
    LIMIT 1
    ) next_flight ON true
GROUP BY a.code
ORDER BY a.code
