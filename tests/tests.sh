#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ "${PYTHON_VERSION}" == 2* ]]; then
    python -V 2>&1 | grep -q "${PYTHON_VERSION}"
    django_msg="It worked!"
else
    python -V | grep -q "${PYTHON_VERSION}"
    django_msg="Get started with Django"
fi

python -c 'import django; print(django.get_version())'

ssh sshd cat /home/wodby/.ssh/authorized_keys | grep -q admin@example.com

#echo "import os" >> myapp/settings.py
#echo "STATIC_ROOT = os.path.join(BASE_DIR, 'static')" >> myapp/settings.py
python manage.py collectstatic --no-input

curl -s localhost:8080 | grep -q "${django_msg}"
curl -sH "Host: localhost" nginx | grep -q "${django_msg}"
curl -sIH "Host: localhost" nginx/static/admin/css/base.css | grep -q "200 OK"
