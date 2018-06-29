#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

ssh_dir=/home/wodby/.ssh

_gotpl() {
    if [[ -f "/etc/gotpl/$1" ]]; then
        gotpl "/etc/gotpl/$1" > "$2"
    fi
}

init_ssh_client() {
    _gotpl "ssh_config.tpl" "${ssh_dir}/config"

    if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
        _gotpl "id_rsa.tpl" "${ssh_dir}/id_rsa"
        chmod -f 600 "${ssh_dir}/id_rsa"
        unset SSH_PRIVATE_KEY
    fi
}

init_sshd() {
    _gotpl "sshd_config.tpl" "/etc/ssh/sshd_config"

    if [[ -n "${SSH_PUBLIC_KEYS}" ]]; then
        _gotpl "authorized_keys.tpl" "${ssh_dir}/authorized_keys"
        unset SSH_PUBLIC_KEYS
    fi

    printenv | xargs -I{} echo {} | awk ' \
        BEGIN { FS = "=" }; { \
            if ($1 != "HOME" \
                && $1 != "PWD" \
                && $1 != "PATH" \
                && $1 != "SHLVL") { \
                \
                print ""$1"="$2"" \
            } \
        }' > "${ssh_dir}/environment"

    sudo gen_ssh_keys "rsa" "${SSHD_HOST_KEYS_DIR}"
}

init_crond() {
    _gotpl "crontab.tpl" "/etc/crontabs/www-data"
}

init_git() {
    git config --global user.email "${GIT_USER_EMAIL}"
    git config --global user.name "${GIT_USER_NAME}"
}

process_templates() {
    _gotpl "pip.conf.tpl" "/home/wodby/.pip/pip.conf"
    _gotpl "gunicorn.py.tpl" "/usr/local/etc/gunicorn/config.py"
}

chmod +x /etc/init.d/gunicorn

sudo init_volumes

init_ssh_client
init_git

process_templates

if [[ "${@:1:2}" == "sudo /usr/sbin/sshd" ]]; then
    init_sshd
elif [[ "${@:1:3}" == "sudo -E crond" ]]; then
    init_crond
fi

exec_init_scripts

if [[ $1 == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    shell_commands=(sh /bin/sh bash /bin/bash)

    if [[ "${shell_commands[*]}" =~ $1 || -f "requirements.txt" ]]; then
        exec "${@}"
    else
        echo "File requirements.txt is missing in working dir ${PWD}"

        trap cleanup SIGINT SIGTERM

        while [ 1 ]; do
            sleep 60 &
            wait $!
        done
    fi
fi
