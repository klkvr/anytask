#!/bin/sh
set -e

#until psql $DATABASE_URL -c '\l'; do
#    >&2 echo "Postgres is unavailable - sleeping"
#    sleep 1
#done

>&2 echo "Postgres is up - continuing"

if [ "$DJANGO_MANAGEPY_MIGRATE" = "on" ]; then
    python manage.py migrate --noinput
fi

chown 1000:1000 -R /var/log/anytask

exec "$@"
