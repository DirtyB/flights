FROM node:16-bullseye

ENV DB_HOST=db
ENV DB_PORT=5432
ENV DB_DATABASE=flights
ENV DB_USER=flights
ENV DB_PASSWORD=flights

COPY . /var/migration

WORKDIR /var/migration

RUN npm install

ENTRYPOINT npx postgrator --host=$DB_HOST --port=$DB_PORT --database=$DB_DATABASE \
            --username=$DB_USER --password=$DB_PASSWORD