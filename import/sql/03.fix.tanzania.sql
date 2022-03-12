UPDATE raw_ariport
SET name = concat(name,'/',country,'/',lon),
    country_code = lat,
    country = 'Tanzania',
    lat = null,
    lon = null
where lat = 'MET';