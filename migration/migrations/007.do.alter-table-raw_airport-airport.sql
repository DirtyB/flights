alter table raw_airport
add column utc_offset_millis numeric(20);

alter table airport
add column utc_offset_millis numeric(20);