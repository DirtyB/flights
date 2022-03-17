SELECT dow,
       count(*)
FROM flight_schedule
         JOIN airport ON flight_schedule.dpt_airport_id = airport.id
         JOIN generate_series(1, 7) dow ON substr(schedule, dow, 1) <> '-'
GROUP BY dow
ORDER BY dow;
