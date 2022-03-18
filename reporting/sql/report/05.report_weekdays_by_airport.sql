SELECT *
FROM crosstab(
             'SELECT airport.code as airport_code,
                dow,
                count(*) filter (where substr(schedule, dow, 1) <> ''-'') count
             FROM flight_schedule
                      JOIN airport ON flight_schedule.dpt_airport_id = airport.id
                      JOIN generate_series(1, 7) dow ON true
             GROUP BY airport_code, dow
             ORDER BY airport_code, dow',
             'SELECT generate_series(1, 7) dow '
         ) AS ct ("airport_code" varchar, "monday" int, "tuesday" int,
                  "wednesday" int, "thursday" int, "friday" int, "saturday" int,
                  "sunday" int);