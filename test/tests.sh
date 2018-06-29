#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

python -V | grep -q "${PYTHON_VERSION}"
