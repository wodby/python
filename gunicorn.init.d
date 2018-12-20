#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

# The following python env vars considered as bad variables: $PYTHONHOME, $PYTHONPATH, $PYTHONINSPECT, $PYTHONUSERBASE
# So we have to set it again.
export PYTHONUSERBASE="${APP_ROOT}/.local"

gunicorn -c /usr/local/etc/gunicorn/config.py --pythonpath "${GUNICORN_PYTHONPATH:-}" "${GUNICORN_APP}"
