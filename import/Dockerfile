FROM node:16-bullseye

ENV PGHOST=db
ENV PGPORT=5432
ENV PGDATABASE=flights
ENV PGUSER=flights
ENV PGPASSWORD=flights

COPY . /var/import

WORKDIR /var/import

RUN npm install

ENTRYPOINT ["/bin/bash", "-c"]