#!/bin/bash

# Run database migrations
python manage.py migrate --noinput

# Start Gunicorn server
exec gunicorn med_adherence.wsgi:application --bind 0.0.0.0:8080
