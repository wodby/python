#!/bin/bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

wait_for_cron() {
    executed=0

    for i in $(seq 1 13); do
        if docker_exec crond cat /mnt/files/cron | grep -q "test"; then
            executed=1
            break
        fi
        echo 'Waiting for cron execution...'
        sleep 5
    done

    if [[ "${executed}" -eq '0' ]]; then
        echo >&2 'Cron failed.'
        exit 1
    fi

    echo 'Cron has been executed!'
}

docker_exec() {
    docker-compose exec "${@}"
}

run_action() {
    docker_exec "${1}" make "${@:2}" -f /usr/local/bin/actions.mk
}

docker-compose up -d

run_action python check-ready max_try=10
docker-compose logs sshd
run_action sshd sh -c "cat /home/wodby/.ssh/authorized_keys"
sleep 5
docker_exec python tests.sh

wait_for_cron

docker-compose down
