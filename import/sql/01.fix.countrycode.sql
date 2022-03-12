UPDATE raw_ariport
SET country_code = country,
    country = lat,
    lat = lon,
    lon = null
WHERE not isnumeric(lat) AND isnumeric(lon);