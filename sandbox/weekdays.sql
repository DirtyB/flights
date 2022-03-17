SELECT dpt_airport_id                                          as airport_id,
       count(*)                                                as dpt_total,
       count(*) filter ( where substr(schedule, 1, 1) <> '-' ) as dpt_fligths_monday,
       count(*) filter ( where substr(schedule, 2, 1) <> '-' ) as dpt_fligths_tuesday,
       count(*) filter ( where substr(schedule, 3, 1) <> '-' ) as dpt_fligths_wenesday,
       count(*) filter ( where substr(schedule, 4, 1) <> '-' ) as dpt_fligths_thursday,
       count(*) filter ( where substr(schedule, 5, 1) <> '-' ) as dpt_fligths_friday,
       count(*) filter ( where substr(schedule, 6, 1) <> '-' ) as dpt_fligths_saturday,
       count(*) filter ( where substr(schedule, 7, 1) <> '-' ) as dpt_fligths_sunday
FROM flight_schedule
GROUP BY dpt_airport_id;


WITH fs_arrival_time AS (
    SELECT fs.*,
           (('2020-01-01'::date + dpt_local_time)::timestamp at time zone dpt_a.timezone + duration)
               at time zone dst_a.timezone as arrival_local_ts
    FROM flight_schedule fs
             JOIN airport dpt_a ON dpt_a.id = fs.dpt_airport_id
             JOIN airport dst_a ON dst_a.id = fs.dst_airport_id
),
     fs_add_days AS (
         SELECT *,
                (arrival_local_ts::date - '2020-01-01'::date) as add_days
         FROM fs_arrival_time
     )


SELECT dst_airport_id                                                                   as airport_id,
       count(*)                                                                         as dst_total,
       count(*) filter ( where substr(schedule, (1 - add_days - 1) % 7 + 1, 1) <> '-' ) as dst_fligths_monday,
       count(*) filter ( where substr(schedule, (2 - add_days - 1) % 7 + 1, 1) <> '-' ) as dst_fligths_tuesday,
       count(*) filter ( where substr(schedule, (3 - add_days - 1) % 7 + 1, 1) <> '-' ) as dst_fligths_wenesday,
       count(*) filter ( where substr(schedule, (4 - add_days - 1) % 7 + 1, 1) <> '-' ) as dst_fligths_thursday,
       count(*) filter ( where substr(schedule, (5 - add_days - 1) % 7 + 1, 1) <> '-' ) as dst_fligths_friday,
       count(*) filter ( where substr(schedule, (6 - add_days - 1) % 7 + 1, 1) <> '-' ) as dst_fligths_saturday,
       count(*) filter ( where substr(schedule, (7 - add_days - 1) % 7 + 1, 1) <> '-' ) as dst_fligths_sunday
FROM fs_add_days
GROUP BY dst_airport_id;