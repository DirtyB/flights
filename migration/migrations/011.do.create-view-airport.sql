create view view_airport(code, name, country_name, lat, lon, timezone) as
SELECT airport.code,
       airport.name,
       c.country_name,
       st_y(airport.coordinates::geometry) AS lat,
       st_x(airport.coordinates::geometry) AS lon,
       airport.timezone
FROM airport
         JOIN country c ON airport.country_id = c.id;

