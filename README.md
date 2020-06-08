# Python Docker Container Images

[![Build Status](https://travis-ci.com/wodby/python.svg?branch=master)](https://travis-ci.com/wodby/python)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/python.svg)](https://hub.docker.com/r/wodby/python)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/python.svg)](https://hub.docker.com/r/wodby/python)
[![Docker Layers](https://images.microbadger.com/badges/image/wodby/python.svg)](https://microbadger.com/images/wodby/python)

## Table of Contents

* [Docker Images](#docker-images)
    * [`-dev`](#-dev)
    * [`-dev-macos`](#-dev-macos)
    * [`-debug`](#-debug)
* [Environment Variables](#environment-variables)
* [Build arguments](#build-arguments)
* [Libraries](#libraries)
* [Changelog](#changelog)    
* [Users and permissions](#users-and-permissions)
* [Crond](#crond)
* [SSHD](#sshd)
* [Adding SSH key](#adding-ssh-key)
* [Complete Python stack](#complete-python-stack)
* [Orchestration Actions](#orchestration-actions)

## Docker Images

❗For better reliability we release images with stability tags (`wodby/python:3.6-X.X.X`) which correspond to [git tags](https://github.com/wodby/python/releases). We strongly recommend using images only with stability tags. 

About images:

* All images are based on Alpine Linux
* Base image: [python](https://github.com/docker-library/python)
* [Travis CI builds](https://travis-ci.com/wodby/python) 
* [Docker Hub](https://hub.docker.com/r/wodby/python) 

Supported tags and respective `Dockerfile` links:

* `3.7`, `3`, `latest` [_(Dockerfile)_]
* `3.6` [_(Dockerfile)_]
* `3.5` [_(Dockerfile)_]
* `3.7-dev`, `3-dev` [_(Dockerfile)_]
* `3.6-dev` [_(Dockerfile)_]
* `3.5-dev` [_(Dockerfile)_]
* `3.7-dev-macos`, `3-dev-macos` [_(Dockerfile)_]
* `3.6-dev-macos` [_(Dockerfile)_]
* `3.5-dev-macos` [_(Dockerfile)_]

[_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)

### `-dev`

Images with `-dev` tag have `sudo` allowed for all commands for `wodby` user.

### `-dev-macos`

Same as `-dev` but the default user/group `wodby` has uid/gid `501`/`20`  to match the macOS default user/group ids.

### `-debug`

Include all changes from `-dev` images and additionally:

* Python compiled with `--with-pydebug` flag
* Python binaries are not stripped from debug symbols

## Environment Variables

| Variable                          | Default value            |
| --------------------------------- | -------------------      |
| `GIT_USER_EMAIL`                  | `wodby@example.com`      |
| `GIT_USER_NAME`                   | `wodby`                  |
| `GUNICORN_APP`                    | `myapp.wsgi:application` |
| `GUNICORN_BACKLOG`                | `2048`                   |
| `GUNICORN_KEEPALIVE`              | `2`                      |
| `GUNICORN_LOGLEVEL`               | `info`                   |
| `GUNICORN_PROC_NAME`              | `Gunicorn`               |
| `GUNICORN_PYTHONPATH`             |                          |
| `GUNICORN_SPEW`                   | `False`                  |
| `GUNICORN_TIMEOUT`                | `30`                     |
| `GUNICORN_WORKER_CLASS`           | `sync`                   |
| `GUNICORN_WORKER_CONNECTIONS`     | `1000`                   |
| `GUNICORN_WORKERS`                | `4`                      |
| `SSH_DISABLE_STRICT_KEY_CHECKING` |                          |
| `SSH_PRIVATE_KEY`                 |                          |
| `SSHD_GATEWAY_PORTS`              | `no`                     |
| `SSHD_HOST_KEYS_DIR`              | `/etc/ssh`               |
| `SSHD_LOG_LEVEL`                  | `INFO`                   |
| `SSHD_PASSWORD_AUTHENTICATION`    | `no`                     |
| `SSHD_PERMIT_USER_ENV`            | `no`                     |
| `SSHD_USE_DNS`                    | `yes`                    |

## Build arguments

| Argument         | Default value |
| ---------------- | ------------- |
| `PYTHON_DEV`     |               |
| `PYTHON_DEBUG`   |               |
| `WODBY_GROUP_ID` | `1000`        |
| `WODBY_USER_ID`  | `1000`        |

Change `WODBY_USER_ID` and `WODBY_GROUP_ID` mainly for local dev version of images, if it matches with existing system user/group ids the latter will be deleted. 

## Libraries

All essential linux libraries are freezed and updates will be reflected in [changelog](#changelog). 

## Changelog

Changes per stability tag reflected in git tags description under [releases](https://github.com/wodby/python/releases). 

## Crond

You can run Crond with this image changing the command to `sudo -E crond -f -d 0` and mounting a crontab file to `./crontab:/etc/crontabs/www-data`. Example crontab file contents:

```
# min	hour	day	month	weekday	command
*/1	*	*	*	*	echo "test" > /mnt/files/cron
```

## SSHD

You can run SSHD with this image by changing the command to `sudo /usr/sbin/sshd -De` and mounting authorized public keys to `/home/wodby/.ssh/authorized_keys`

## Adding SSH key

You can add a private SSH key to the container by mounting it to `/home/wodby/.ssh/id_rsa`

## Users and permissions

Default container user is `wodby:wodby` (UID/GID `1000`). Gunicorn runs from `www-data:www-data` user (UID/GID `82`) by default. User `wodby` is a part of `www-data` group.

Codebase volume `$APP_ROOT` (`/usr/src/app`) owned by `wodby:wodby`. Files volume `$FILES_DIR` (`/mnt/files`) owned by `www-data:www-data` with `775` mode.

#### Helper scripts 

* `files_chmod` – in case you need write access for `wodby` user to a file/dir generated by `www-data` on this volume run `sudo files_chmod [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change the mode to `ug=rwX,o=rX`

* `files_chown` – in case you manually uploaded files under `wodby` user to files volume and want to change the ownership of those files to `www-data` run `sudo files_chown [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change ownership to `www-data:www-data`

## Complete Python stack

See https://github.com/wodby/docker4python

## Orchestration Actions

Usage:
```
make COMMAND [params ...]

commands:
    migrate
    check-ready [host max_try wait_seconds delay_seconds]
    files-import source
    files-link public_dir 
```
