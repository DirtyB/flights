FROM postgis/postgis:14-3.2

ENV POSTGRES_USER=flights
ENV POSTGRES_PASSWORD=flights
ENV POSTGRES_DB=flights

ENV POSTGRES_HOST=db
ENV POSTGRES_PORT=5432

COPY . /var/generator/
WORKDIR /var/generator

ENTRYPOINT ./run_sql.sh