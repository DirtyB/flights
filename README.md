# flights: Test project for Alar Studios

by Boris Tolstukha (boris.tolstukha@gmail.com)

## Steps to run

### Prerequisites

You need **docker** (https://docs.docker.com/get-docker/) 
and **docker-compose** (https://docs.docker.com/compose/install/) 
installed to run this project.

### Build project

```shell
$ ./build_all.sh
```

### Run database and apply migrations

```shell
$ docker-compose up -d db
$ docker-compose up migratiion
```

PostgreSQL database will be accessible on `localhost:5432`. 

Use user `flights`, password `flights`, 
database name `flights` to access it with any convenient tool.

Sources for migrations are here: https://github.com/DirtyB/flights/tree/master/migration/migrations

### Download data (optional step)

Downloads airports data to files and fixes JSON syntax in those files.

This step is optional. Downloaded data is stored in repository.

```shell
$ docker-compose up data_download
```

- Source for data download: https://github.com/DirtyB/flights/blob/master/import/download.js
- Source for JSON fix: https://github.com/DirtyB/flights/blob/master/import/fix.js
- Downloaded and fixed data: https://github.com/DirtyB/flights/tree/master/import/data

### Import raw data

Imports data from JSON files into intermediate table `raw_airport` 
and fixes errors in data to comply to business logic.

```shell
$ docker-compose up data_import
```

- Source for data import: https://github.com/DirtyB/flights/blob/master/import/import.js
- SQLs to fix data: https://github.com/DirtyB/flights/tree/master/import/sql/fix

### Download timezone data (optional step)

Downloads timezone data from [AskGeo](https://askgeo.com/) to JSON files.

This step is optional and won't work as-is, as AskGeo has limitations for free account.
To update timezone data replace ASKGEO_USER and ASKGEO_TOKEN 
[here](https://github.com/DirtyB/flights/blob/master/import/.env) 
and rebuild project.

Downloaded data is stored in repository.

```shell
$ docker-compose up tz_download
```

- Source for timezone data download: https://github.com/DirtyB/flights/blob/master/import/download_tz.js
- Downloaded timezone data: https://github.com/DirtyB/flights/tree/master/import/tz_data


### Commit data

Combine imported raw airports data and downloaded timezone data to final tables 
`country` and `airport` .

```shell
$ docker-compose up data_commit
```

- Source for timezone data import: https://github.com/DirtyB/flights/blob/master/import/enrich.js
- SQLs for data commit: https://github.com/DirtyB/flights/tree/master/import/sql/commit

### Generate flights schedule and movements

Generates data in tables 
- `flight_schedule` - schedule for flights by weekdays 
- `flight` - scheduled flights from January to March 2020 
- `flight_movement` - actual arrivals and departures of the flights 

```shell
$ docker-compose up generator
```

- SQLs for data generation: https://github.com/DirtyB/flights/tree/master/generator/sql

## View data 

Use any convenient tool to connect to database to view data and generate reports.
(See run database section).

### Imported data

Airports

```sql
SELECT * FROM view_airport
ORDER BY code;
```

### Generated data

Flight schedule

```sql
SELECT * FROM view_flight_schedule
ORDER BY flight_number;
```

Flight movements

```sql
SELECT * FROM view_flight_movement
ORDER BY date, time_utc;
```

### Reports

#### [General report on schedule](https://github.com/DirtyB/flights/blob/master/reporting/sql/report/01.report_general_schedule.sql)

For each airport: 
- number of departing flights (must be 3-7), 
- earliest flight local time (must be later then 17:00),
- latest flight local time (must be between 22:30 and 23:00),
- shortest time between flights (must be not less than 30 minutes)

#### [General report on movements](https://github.com/DirtyB/flights/blob/master/reporting/sql/report/02.report_general_movements.sql)

- `completion_rate` - rate of actually completed flights among planned (must be 0.95)
- `late_rate` - rate of late flights among completed (must be 0.2)
- `delayed_among_late_rate` - rate of delayed flights among late flights (must be 0.5)
- `delayed_not_late_rate` - rate of delayed but not late flights among completed (must be 0.3)
- `early_arrival_rate` - rate of flights that arrived early among completed (must be 0.05)
- _etc_

#### [Report on late flights](https://github.com/DirtyB/flights/blob/master/reporting/sql/report/03.report_late_total.sql)

- `planned` - total planned flights
- `completed` - total completed flights
- `cancelled` - total cancelled flights
- `late_delayed` - flights late because of being delayed
- `late_not_delayed` - flights late while not being delayed (weather etc.)
- `cancelled_rate` - rate of cancelled flights among planned (must be 0.05)
- `late_delayed_rate` - rate of flights late because of being delayed among completed (must be 0.1)
- `late_delayed_rate` - rate of flights late while not being delayed among completed (must be 0.1)

#### [Report on late flights by destination country](https://github.com/DirtyB/flights/blob/master/reporting/sql/report/04.report_late_by_country.sql-)

For each country all metrics of the report above regarding flights arriving to this country.

#### [Report on weekdays by airport](https://github.com/DirtyB/flights/blob/master/reporting/sql/report/05.report_weekdays_by_airport.sql)

For each airport and each weekday - number of flights departing from the airport on that weekday.

#### [Report on weekdays](https://github.com/DirtyB/flights/blob/master/reporting/sql/report/06.report_weekdays_total.sql)

For each weekday - total number of flights departing on that weekday.

## Exported data:

As CSV:

- [Imported data](https://github.com/DirtyB/flights/tree/master/reporting/sql/imported)
- [Generated data](https://github.com/DirtyB/flights/tree/master/reporting/sql/generated)
- [Reports](https://github.com/DirtyB/flights/tree/master/reporting/sql/report)

Full dump of database with that data:
https://github.com/DirtyB/flights/blob/master/reporting/dump/flights.dump