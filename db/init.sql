DO
$$
    BEGIN
        IF NOT EXISTS(
                SELECT *
                FROM pg_catalog.pg_user
                WHERE usename = 'flights')
        THEN
            CREATE ROLE flights LOGIN
                ENCRYPTED PASSWORD 'flights'
                SUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION;
        END IF;
    END
$$;

CREATE DATABASE flights OWNER flights;

-- CREATE SCHEMA IF NOT EXISTS flights.flights;
