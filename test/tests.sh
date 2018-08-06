#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

python -V | grep -q "${PYTHON_VERSION}"

cat ~/.ssh/id_rsa
ssh -vvv sshd cat /home/wodby/.ssh/authorized_keys
#| grep -q admin@example.com

curl -s nginx | grep -q "Hello, World!"
curl -s localhost:8080 | grep -q "Hello, World!"