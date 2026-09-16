ARG PYTHON_VER

FROM python:${PYTHON_VER}-alpine AS python-security

ARG PYTHON_VER
COPY patches/python310-xml-hash-salt.patch /tmp/python310-xml-hash-salt.patch

# Backport the upstream XML hash-flooding fix until Python 3.10.22 is released.
# Other Python versions keep the official interpreter unchanged.
RUN set -eux; \
    if [ "${PYTHON_VER}" = "3.10.21" ]; then \
        apk add --no-cache build-base bzip2-dev gdbm-dev libffi-dev \
            libnsl-dev libtirpc-dev linux-headers ncurses-dev openssl-dev \
            readline-dev sqlite-dev tcl-dev tk-dev util-linux-dev xz-dev zlib-dev; \
        wget -O /tmp/python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tar.xz"; \
        echo 'a0da1e72132e950154eca0f6f47d5db828454700de20e5113667940d81e0db04  /tmp/python.tar.xz' | sha256sum -c -; \
        mkdir /tmp/python-src; \
        tar -xJf /tmp/python.tar.xz --strip-components=1 -C /tmp/python-src; \
        cd /tmp/python-src; \
        patch -p1 < /tmp/python310-xml-hash-salt.patch; \
        ./configure --enable-shared --enable-loadable-sqlite-extensions --with-ensurepip; \
        make -j2 EXTRA_CFLAGS='-DTHREAD_STACK_SIZE=0x100000'; \
        make install; \
        ./python -m test test_pyexpat test_xml_etree test_xml_etree_c; \
        rm -rf /usr/local/lib/python3.10/test /usr/local/lib/libpython*.a; \
    fi

FROM python:${PYTHON_VER}-alpine
COPY --from=python-security /usr/local/ /usr/local/

LABEL com.wodby.ci.cache="uv"

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

ENV GUNICORN_APP="myapp.wsgi:application" \
    PIP_USER=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/wodby/.local/bin:${PATH}"

ARG TARGETPLATFORM

# Upgrade inherited packages even when their existing versions satisfy dependencies.
RUN set -xe; \
    apk upgrade --no-cache; \
    PIP_USER=0 python -m pip install --no-cache-dir --upgrade pip setuptools wheel; \
    \
#    addgroup -g 82 -S www-data; \
    adduser -u 82 -D -S -G www-data www-data; \
    \
    # Delete existing user/group if uid/gid occupied. \
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
    apk add --update --no-cache -t .wodby-python-run-deps \
        bash \
        ca-certificates \
        curl \
        freetype \
        git \
        gmp \
        gzip \
        icu-libs \
        imagemagick \
        less \
        libbz2 \
        libjpeg-turbo-utils \
        libjpeg-turbo \
        libldap \
        libmemcached-libs \
        libpng \
        librdkafka \
        libxslt \
        make \
        mariadb-client \
        mariadb-connector-c \
        nano \
        openssh \
        openssh-client \
        patch \
        postgresql-client \
        rabbitmq-c \
        rsync \
        su-exec \
        sudo \
        tar \
        tig \
        tmux \
        unzip \
        wget \
        yaml; \
    \
    # Install redis-cli. \
    apk add --update --no-cache redis; \
    mv /usr/bin/redis-cli /tmp/; \
    apk del --purge redis; \
    deluser redis; \
    mv /tmp/redis-cli /usr/bin; \
    \
    if [[ -n "${PYTHON_DEV}" ]]; then \
        apk add --update --no-cache -t .wodby-python-build-deps \
            build-base \
            gcc \
            imagemagick-dev \
            jpeg-dev \
            libffi-dev \
            linux-headers \
            mariadb-dev \
            musl-dev \
            postgresql-dev; \
    fi; \
    \
    # Download helper scripts. \
    dockerplatform=${TARGETPLATFORM:-linux/amd64}; \
    gotpl_url="https://github.com/wodby/gotpl/releases/latest/download/gotpl-${dockerplatform/\//-}.tar.gz"; \
    wget -qO- "${gotpl_url}" | tar xz --no-same-owner -C /usr/local/bin; \
    git clone https://github.com/wodby/alpine /tmp/alpine; \
    cd /tmp/alpine; \
    latest=$(git describe --abbrev=0 --tags); \
    git checkout "${latest}"; \
    mv /tmp/alpine/bin/* /usr/local/bin; \
    \
    { \
        echo 'export PS1="\u@$(hostname):\w $ "'; \
        echo "export PATH=${PATH}"; \
    } | tee /home/wodby/.shrc; \
    \
    cp /home/wodby/.shrc /home/wodby/.bashrc; \
    cp /home/wodby/.shrc /home/wodby/.bash_profile; \
    \
    curl -LsSf https://astral.sh/uv/install.sh | su-exec wodby sh; \
    \
    # Configure sudoers \
    { \
        echo "Defaults secure_path=\"$PATH\""; \
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
EXPOSE 8080

COPY --chown=wodby:wodby gunicorn.init.d /etc/init.d/gunicorn
COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY bin /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/etc/init.d/gunicorn"]
