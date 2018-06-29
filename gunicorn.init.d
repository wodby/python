#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

gunicorn -c /usr/local/etc/gunicorn/config.py "${GUNICORN_APP}"
