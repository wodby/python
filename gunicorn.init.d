#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

export PYTHONUSERBASE="${APP_ROOT}/.local"

minor="${PYTHON_VERSION%.*}"
export PYTHONPATH="/usr/local/lib/python${minor}:${PYTHONUSERBASE}/lib/python${minor}/site-packages"

gunicorn -c /usr/local/etc/gunicorn/config.py "${GUNICORN_APP}"
