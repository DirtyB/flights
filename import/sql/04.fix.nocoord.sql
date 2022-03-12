UPDATE raw_ariport
SET name = concat(name,'/',country),
    country_code = lat,
    country = lon,
    lat = null,
    lon = null
where not isnumeric(lat) AND not isnumeric(lon);