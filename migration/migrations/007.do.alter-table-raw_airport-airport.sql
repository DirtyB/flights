alter table raw_airport
add column timezone varchar(50);

alter table airport
add column timezone varchar(50);