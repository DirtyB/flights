UPDATE raw_ariport
SET name = concat(name,'/',country,'/',lat),
    country_code = lon,
    country = 'Venezuela (Bolivarian Republic of)',
    lat = null,
    lon = null
where lon = 'VEN';