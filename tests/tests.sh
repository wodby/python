#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ "${PYTHON_VERSION}" == 2* ]]; then
    python -V 2>&1 | grep -q "${PYTHON_VERSION}"
else
    python -V | grep -q "${PYTHON_VERSION}"
fi

python -c 'import django; print(django.get_version())'

ssh sshd cat /home/wodby/.ssh/authorized_keys | grep -q admin@example.com
echo "STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')" >> mysite/settings.py
python manage.py collectstatic --no-input

curl -s localhost:8080 | grep -q "Get started with Django"
curl -sH "Host: localhost" nginx | grep -q "Get started with Django"
curl -sIH "Host: localhost" nginx/static/admin/css/base.css | grep "200 OK"
