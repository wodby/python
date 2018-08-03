#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

python -V | grep -q "${PYTHON_VERSION}"

ssh sshd echo 123 | grep -q 123

curl -s nginx | grep -q "Hello, World!"
curl -s localhost:8080 | grep -q "Hello, World!"