#!/bin/bash -e
#
#psql -v ON_ERROR_STOP=1 --username "flights" --dbname "flights" <<-EOSQL
#    CREATE SCHEMA IF NOT EXISTS flights;
#EOSQL