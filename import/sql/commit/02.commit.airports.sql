DO
$$
    BEGIN
        IF (SELECT count(*) FROM airport) = 0
        THEN
            INSERT INTO airport (code, name, country_id, coordinates)
            SELECT code,
                   name,
                   c.id     country_id,
                   (CASE
                        WHEN lat is not null AND lon IS NOT NULL THEN concat('POINT(', lat, ' ', lon, ')')::geography
                        ELSE null
                       END) coordinates
            FROM raw_airport
                     JOIN country c on raw_airport.country = c.country_name;
        ELSE
            RAISE NOTICE 'table "airport" is not empty, skipping';
        END IF;
    END
$$;





