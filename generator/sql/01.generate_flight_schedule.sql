with euro_ports as
         (SELECT *
          FROM airport
          WHERE (code like 'E%' or code like 'L%' or code = 'BKPR'))
INSERT INTO flight_schedule (flight_number, dpt_airport_id, dst_airport_id, plaintype_id, schedule, dpt_local_time, duration)
SELECT LPAD((row_number() over ())::text, 4, '0') as flight_number,
       dpt.id                                     as dpt_airport_id,
       dst.id                                     as dst_airport_id,
       aircraft.id                                as planetype_id,
       CONCAT(
               CASE WHEN (schedule_factor >> 0) % 2 = 1 THEN 'M' ELSE '-' END,
               CASE WHEN (schedule_factor >> 1) % 2 = 1 THEN 'T' ELSE '-' END,
               CASE WHEN (schedule_factor >> 2) % 2 = 1 THEN 'W' ELSE '-' END,
               CASE WHEN (schedule_factor >> 3) % 2 = 1 THEN 'T' ELSE '-' END,
               CASE WHEN (schedule_factor >> 4) % 2 = 1 THEN 'F' ELSE '-' END,
               CASE WHEN (schedule_factor >> 5) % 2 = 1 THEN 'S' ELSE '-' END,
               CASE WHEN (schedule_factor >> 6) % 2 = 1 THEN 'S' ELSE '-' END
           )                                      as schedule,
       local_time                                 as dpt_local_time,
       interval '1' minute * duration_minutes     as duration
FROM (SELECT *,
             floor(random() * 5 + 3)::int as quan,
             random()                     as seed
      FROM euro_ports) dpt
         JOIN LATERAL (

    WITH apt AS (
        SELECT id
        FROM euro_ports
        WHERE euro_ports.id <> dpt.id
          AND ST_Distance(dpt.coordinates, euro_ports.coordinates) < 8E+6
        ORDER BY random()
        LIMIT dpt.quan
    ),
         rand AS (
             SELECT *,
                    row_number() over () as rnum,
                    random()             as seed
             FROM apt
         ),
         last(last_time) AS (
             VALUES (1380 - floor(dpt.seed * 30)::int)
         ),
         minutes AS (
             SELECT rand.*,
                    last.*,
                    floor((last.last_time - 1020 - (cnt - 1) * 30) * seed / g.sum) rand_min
             FROM rand
                      JOIN (SELECT sum(seed) sum, count(*) cnt from rand) g on true
                      JOIN last on true
         ),
         local_dpt_times AS (
             SELECT m.*,
                    last_time - 30 * (rnum - 1) -
                    coalesce((SELECT sum(rand_min) FROM minutes m2 WHERE m2.rnum < m.rnum), 0) local_time_min
             FROM minutes m
         )
    SELECT airport.*,
           ldt.local_time_min,
           ldt.seed,
           to_timestamp(ldt.local_time_min * 60)::time       as local_time,
           ST_Distance(dpt.coordinates, airport.coordinates) as distance
    FROM airport
             join local_dpt_times ldt on airport.id = ldt.id

    ) dst ON true
         JOIN LATERAL (SELECT *,
                              ceil(random() * 255)::int                     as schedule_factor,
                              ceil(60 * dst.distance / (1852 * speed))::int as duration_minutes
                       FROM planetype
                       ORDER BY random() + dpt.seed
                       LIMIT 1) aircraft on true
