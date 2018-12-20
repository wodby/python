ARG BASE_IMAGE_TAG

FROM wodby/base-python:${BASE_IMAGE_TAG}

ARG PYTHON_DEV

ARG WODBY_USER_ID=1000
ARG WODBY_GROUP_ID=1000

ENV PYTHON_DEV="${PYTHON_DEV}" \
    SSHD_PERMIT_USER_ENV="yes"

ENV APP_ROOT="/usr/src/app" \
    CONF_DIR="/usr/src/app" \
    FILES_DIR="/mnt/files" \
    SSHD_HOST_KEYS_DIR="/etc/ssh" \
    ENV="/home/wodby/.shrc" \
    \
    GIT_USER_EMAIL="wodby@example.com" \
    GIT_USER_NAME="wodby"

ENV GUNICORN_APP="main:app" \
    PIP_USER=1 \
    PYTHONUSERBASE="${APP_ROOT}/.local" \
    PYTHONUNBUFFERED=1 \
    PATH="${APP_ROOT}/.local/bin:${PATH}"

RUN set -xe; \
    \
    addgroup -g 82 -S www-data; \
    adduser -u 82 -D -S -G www-data www-data; \
    \
    # Delete existing user/group if uid/gid occupied.
    existing_group=$(getent group "${WODBY_GROUP_ID}" | cut -d: -f1); \
    if [[ -n "${existing_group}" ]]; then delgroup "${existing_group}"; fi; \
    existing_user=$(getent passwd "${WODBY_USER_ID}" | cut -d: -f1); \
    if [[ -n "${existing_user}" ]]; then deluser "${existing_user}"; fi; \
    \
	addgroup -g "${WODBY_GROUP_ID}" -S wodby; \
	adduser -u "${WODBY_USER_ID}" -D -S -s /bin/bash -G wodby wodby; \
	adduser wodby www-data; \
	sed -i '/^wodby/s/!/*/' /etc/shadow; \
    \
    apk add --update --no-cache -t .python-rundeps \
        freetype=2.9.1-r1 \
        git \
        gmp=6.1.2-r1 \
        icu-libs=60.2-r2 \
        imagemagick=7.0.7.32-r1 \
        less \
        libbz2=1.0.6-r6 \
        libjpeg-turbo=1.5.3-r3 \
        libjpeg-turbo-utils \
        libldap=2.4.46-r0 \
        libmemcached-libs=1.0.18-r2 \
        libpng=1.6.34-r1 \
        librdkafka=0.11.4-r1 \
        libxslt=1.1.32-r0 \
        make \
        mariadb-client=10.2.15-r0 \
        nano \
        openssh \
        openssh-client \
        postgresql-client=10.5-r0 \
        rabbitmq-c=0.8.0-r4 \
        patch \
        rsync \
        su-exec \
        sudo \
        tig \
        tmux \
        yaml=0.1.7-r0; \
    \
    # Install redis-cli.
    apk add --update --no-cache redis; \
    mv /usr/bin/redis-cli /tmp/; \
    apk del --purge redis; \
    deluser redis; \
    mv /tmp/redis-cli /usr/bin; \
    \
    if [[ -n "${PYTHON_DEV}" ]]; then \
        apk add --update --no-cache -t .python-build-deps \
            build-base \
            imagemagick-dev \
            libffi-dev \
            linux-headers \
            mariadb-dev \
            postgresql-dev; \
    fi; \
    \
    { \
        echo 'export PS1="\u@${WODBY_APP_NAME:-python}.${WODBY_ENVIRONMENT_NAME:-container}:\w $ "'; \
        echo "export PATH=${PATH}"; \
    } | tee /home/wodby/.shrc; \
    \
    cp /home/wodby/.shrc /home/wodby/.bashrc; \
    cp /home/wodby/.shrc /home/wodby/.bash_profile; \
    \
    # Configure sudoers
    { \
        echo 'Defaults env_keep += "APP_ROOT FILES_DIR"' ; \
        \
        if [[ -n "${PYTHON_DEV}" ]]; then \
            echo 'wodby ALL=(root) NOPASSWD:SETENV:ALL'; \
        else \
            echo -n 'wodby ALL=(root) NOPASSWD:SETENV: ' ; \
            echo -n '/usr/local/bin/files_chmod, ' ; \
            echo -n '/usr/local/bin/files_chown, ' ; \
            echo -n '/usr/local/bin/files_sync, ' ; \
            echo -n '/usr/local/bin/gen_ssh_keys, ' ; \
            echo -n '/usr/local/bin/init_container, ' ; \
            echo -n '/etc/init.d/gunicorn, ' ; \
            echo -n '/usr/sbin/sshd, ' ; \
            echo '/usr/sbin/crond' ; \
        fi; \
    } | tee /etc/sudoers.d/wodby; \
    \
    echo "TLS_CACERTDIR /etc/ssl/certs/" >> /etc/openldap/ldap.conf; \
    \
    install -o wodby -g wodby -d \
        "${APP_ROOT}" \
        "${CONF_DIR}" \
        /usr/local/etc/gunicorn/ \
        /home/wodby/.pip \
        /home/wodby/.ssh; \
    \
    install -o www-data -g www-data -d \
        /home/www-data/.ssh \
        "${FILES_DIR}/public" \
        "${FILES_DIR}/private"; \
    \
    chmod -R 775 "${FILES_DIR}"; \
    su-exec wodby touch /usr/local/etc/gunicorn/config.py; \
    \
    touch /etc/ssh/sshd_config; \
    chown wodby: /etc/ssh/sshd_config /home/wodby/.*; \
    \
    rm -rf \
        /etc/crontabs/root \
        /tmp/* \
        /var/cache/apk/*

USER wodby

WORKDIR ${APP_ROOT}
EXPOSE 8000

COPY --chown=wodby:wodby gunicorn.init.d /etc/init.d/gunicorn
COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY bin /usr/local/bin/

ONBUILD COPY requirements.txt ./
ONBUILD RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "/etc/init.d/gunicorn"]
