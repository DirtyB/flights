with euro_ports as
         (SELECT *
          FROM airport
          WHERE (code like 'E%' or code like 'L%' or code = 'BKPR'))
INSERT INTO flight_schedule (flight_number, dpt_airport_id, dst_airport_id, plaintype_id, schedule, dpt_time_utc, dst_time_utc)
SELECT LPAD((row_number() over ())::text, 4, '0')                       as flight_number,
       dpt.id                                                           as dpt_airport_id,
       dst.id                                                           as dst_airport_id,
       aircraft.id                                                      as planetype_id,
       CONCAT(
               CASE WHEN (schedule_factor >> 0)::bit(1) <> 0::bit THEN 'M' ELSE '-' END,
               CASE WHEN (schedule_factor >> 1)::bit(1) <> 0::bit THEN 'T' ELSE '-' END,
               CASE WHEN (schedule_factor >> 2)::bit(1) <> 0::bit THEN 'W' ELSE '-' END,
               CASE WHEN (schedule_factor >> 3)::bit(1) <> 0::bit THEN 'T' ELSE '-' END,
               CASE WHEN (schedule_factor >> 4)::bit(1) <> 0::bit THEN 'F' ELSE '-' END,
               CASE WHEN (schedule_factor >> 5)::bit(1) <> 0::bit THEN 'S' ELSE '-' END,
               CASE WHEN (schedule_factor >> 6)::bit(1) <> 0::bit THEN 'S' ELSE '-' END
           )                                                            as schedule,
       to_timestamp(dst.utc_time_seconds)::time                         as dpt_time_utc,
       to_timestamp(dst.utc_time_seconds + duration_minutes * 60)::time as dst_time_utc
FROM (SELECT *,
             floor(random() * 5 + 3)::int as quan,
             random()                     as seed
      FROM euro_ports) dpt
         JOIN LATERAL (

    WITH apt AS (
        SELECT id
        FROM euro_ports
        WHERE euro_ports.id <> dpt.id
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
                    last_time - 30 * rnum -
                    coalesce((SELECT sum(rand_min) FROM minutes m2 WHERE m2.rnum < m.rnum), 0) local_time_min
             FROM minutes m
         )
    SELECT airport.*,
           ldt.local_time_min,
           ldt.seed,
           (ldt.local_time_min * 60 - airport.utc_offset_millis / 1000)::int utc_time_seconds,
           ST_Distance(dpt.coordinates, airport.coordinates)                 distance
    FROM airport
             join local_dpt_times ldt on airport.id = ldt.id

    ) dst ON true
         JOIN LATERAL (SELECT *,
                              floor(random() * 254)::int + 1 as             schedule_factor,
                              ceil(60 * dst.distance / (1852 * speed))::int duration_minutes
                       FROM planetype
                       ORDER BY random()
                       LIMIT 1) aircraft on true
