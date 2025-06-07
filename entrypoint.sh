#!/bin/bash

echo "Running migrations..."
python manage.py migrate

echo "Creating superuser..."
echo "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
User.objects.create_superuser('admin', 'mohdrashid.p7@gmail.com', 'Admin@78699')" \
| python manage.py shell

echo "Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:8080 med_adherence.wsgi:application
