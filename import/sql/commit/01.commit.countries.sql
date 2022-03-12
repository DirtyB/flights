DO
$$
    BEGIN
        IF (SELECT count(*) FROM country) = 0
        THEN
            INSERT INTO country (country_name, country_code)
            SELECT c.country,
                   (SELECT country_code
                    FROM raw_airport a
                    WHERE a.country = c.country
                    ORDER BY country_code NULLS LAST
                    limit 1) country_code
            FROM (SELECT DISTINCT country FROM raw_airport) c;
        ELSE
            RAISE NOTICE 'table "country" is not empty, skipping';
        END IF;
    END
$$;



