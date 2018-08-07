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

ssh sshd cat /home/wodby/.ssh/authorized_keys | grep -q admin@example.com

curl -s nginx | grep -q "Hello, World!"
curl -s localhost:8080 | grep -q "Hello, World!"