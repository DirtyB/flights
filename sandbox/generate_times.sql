WITH
    rand AS (
        SELECT rnum, random() rand_value
        FROM generate_series(0, 3) rnum
    ),
    last(last_time) AS (
        VALUES (1380 - floor(random() * 30)::int)
    ),
    minutes AS (
        SELECT rnum,
               floor((last.last_time - 1020 - (cnt - 1) * 30) * rand_value / g.sum) rand_min,
               last.*
        FROM rand
                 JOIN (SELECT sum(rand_value) sum, count(*) cnt from rand) g on true
                 JOIN last on true
    ),
    local_dpt_times AS (
        SELECT last_time - 30 * rnum -
               coalesce((SELECT sum(rand_min) FROM minutes m2 WHERE m2.rnum < m.rnum), 0) local_time_min
        FROM minutes m
    )

SELECT *
FROM local_dpt_times;