#!/bin/sh

echo "⏳ Waiting for MySQL at $SQL_HOST:$SQL_PORT..."

# Wait until MySQL port is open
while ! nc -z $SQL_HOST $SQL_PORT; do
  sleep 1
done

echo "✅ MySQL is up. Starting Django..."

python manage.py migrate
python manage.py loaddata products.json
uvicorn nagp_kube_devops_demo.asgi:application --host 0.0.0.0 --port 8000
