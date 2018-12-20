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

init_sshd() {
    _gotpl "sshd_config.tmpl" "/etc/ssh/sshd_config"

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

init_git() {
    git config --global user.email "${GIT_USER_EMAIL}"
    git config --global user.name "${GIT_USER_NAME}"
}

process_templates() {
    _gotpl "ssh_config.tmpl" "${ssh_dir}/config"
    _gotpl "gunicorn.py.tmpl" "/usr/local/etc/gunicorn/config.py"
}

sudo init_container

init_git
process_templates

chmod +x /etc/init.d/gunicorn

if [[ "${@:1:2}" == "sudo /usr/sbin/sshd" ]]; then
    init_sshd
fi

exec_init_scripts

if [[ "${1}" == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    exec "${@}"
fi
