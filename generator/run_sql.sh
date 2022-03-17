#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

export PGPASSWORD=${POSTGRES_PASSWORD:-flights}

for f in "$SCRIPT_DIR"/sql/*.sql;
do
    echo "applying $f"
    psql "${POSTGRES_DB:-flights}" "${POSTGRES_USER:-flights}" -f "$f" \
      --host "${POSTGRES_HOST:-localhost}" --port "${POSTGRES_PORT:-5432}"
done