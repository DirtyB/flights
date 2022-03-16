alter table airport
drop column utc_offset_millis;

alter table raw_airport
drop column utc_offset_millis;