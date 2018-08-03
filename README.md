# Python Docker Container Images

[![Build Status](https://travis-ci.com/wodby/python.svg?branch=master)](https://travis-ci.com/wodby/python)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/python.svg)](https://hub.docker.com/r/wodby/python)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/python.svg)](https://hub.docker.com/r/wodby/python)
[![Docker Layers](https://images.microbadger.com/badges/image/wodby/python.svg)](https://microbadger.com/images/wodby/python)

## Table of Contents

* [Docker Images](#docker-images)
* [Environment Variables](#environment-variables)
* [Build arguments](#build-arguments)    
* [`-dev` images](#-dev-images)
* [`-dev-macos` images](#-dev-macos-images)
* [`-debug` images](#-debug-images)
* [Users and permissions](#users-and-permissions)
* [Crond](#crond)
* [SSHD](#sshd)
* [Orchestration Actions](#orchestration-actions)

## Docker Images

❗For better reliability we release images with stability tags (`wodby/python:3.6-X.X.X`) which correspond to [git tags](https://github.com/wodby/python/releases). We strongly recommend using images only with stability tags. 

About images:

* All images are based on Alpine Linux 3.8
* [Travis CI builds](https://travis-ci.com/wodby/python) 
* [Docker Hub](https://hub.docker.com/r/wodby/python) 
* [`-dev`](#-dev-images) and [`-debug`](#-debug-images) images have a few differences

Supported tags and respective `Dockerfile` links:

* `3.7`, `3`, `latest` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.6` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.5` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.4` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `2.7`, `2` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.7-dev`, `3-dev` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.6-dev` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.5-dev` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.4-dev` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `2.7-dev`, `2-dev` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.7-dev-macos`, `3-dev-macos` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.6-dev-macos` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.5-dev-macos` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `3.4-dev-macos` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)
* `2.7-dev-macos`, `2-dev-macos` [_(Dockerfile)_](https://github.com/wodby/python/tree/master/Dockerfile)

## Environment Variables

| Variable                          | Default value       |
| --------------------------------- | ------------------- |
| `GIT_USER_EMAIL`                  | `wodby@example.com` |
| `GIT_USER_NAME`                   | `wodby`             |
| `GUNICORN_BACKLOG`                | `2048`              |
| `GUNICORN_WORKERS`                | `4`                 |
| `GUNICORN_WORKER_CLASS`           | `sync`              |
| `GUNICORN_WORKER_CONNECTIONS`     | `1000`              |
| `GUNICORN_TIMEOUT`                | `30`                |
| `GUNICORN_KEEPALIVE`              | `2`                 |
| `GUNICORN_SPEW`                   | `False`             |
| `GUNICORN_USER`                   | `www-data`          |
| `GUNICORN_GROUP`                  | `www-data`          |
| `GUNICORN_LOGLEVEL`               | `info`              |
| `GUNICORN_PROC_NAME`              | `Gunicorn`          |
| `SSH_PRIVATE_KEY`                 |                     |
| `SSH_DISABLE_STRICT_KEY_CHECKING` |                     |
| `SSHD_GATEWAY_PORTS`              | `no`                |
| `SSHD_HOST_KEYS_DIR`              | `/etc/ssh`          |
| `SSHD_LOG_LEVEL`                  | `INFO`              |
| `SSHD_PASSWORD_AUTHENTICATION`    | `no`                |
| `SSHD_PERMIT_USER_ENV`            | `no`                |
| `SSHD_USE_DNS`                    | `yes`               |

## Build arguments

| Argument         | Default value |
| ---------------- | ------------- |
| `PYTHON_DEV`     |               |
| `PYTHON_DEBUG`   |               |
| `WODBY_GROUP_ID` | `1000`        |
| `WODBY_USER_ID`  | `1000`        |

Change `WODBY_USER_ID` and `WODBY_GROUP_ID` mainly for local dev version of images, if it matches with existing system user/group ids the latter will be deleted. 

## `-dev` Images

Images with `-dev` tag have `sudo` allowed for all commands for `wodby` user

## `-dev-macos` Images

Same as `-dev` but the default user/group `wodby` has uid/gid `501`/`20`  to match the macOS default user/group ids.

## `-debug` Images

Include all changes from `-dev` images and additionally:

* Python compiled with `--with-pydebug` flag
* Python binaries are not stripped from debug symbols

## Crond

You can run Crond with this image changing the command to `sudo -E crond -f -d 0` and mounting a crontab file to `./crontab:/etc/crontabs/www-data`. Example crontab file contents:

```
# min	hour	day	month	weekday	command
*/1	*	*	*	*	echo "test" > /mnt/files/cron
```

## SSHD

You can run SSHD with this image by changing the command to `sudo /usr/sbin/sshd -De` and mounting authorized public keys to `/home/wodby/.ssh/authorized_keys`

## Users and permissions

Default container user is `wodby:wodby` (UID/GID `1000`). Gunicorn runs from `www-data:www-data` user (UID/GID `82`) by default. User `wodby` is a part of `www-data` group.

Codebase volume `$APP_ROOT` (`/usr/src/app`) owned by `wodby:wodby`. Files volume `$FILES_DIR` (`/mnt/files`) owned by `www-data:www-data` with `775` mode.

#### Helper scripts 

* `files_chmod` – in case you need write access for `wodby` user to a file/dir generated by `www-data` on this volume run `sudo files_chmod [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change the mode to `ug=rwX,o=rX`

* `files_chown` – in case you manually uploaded files under `wodby` user to files volume and want to change the ownership of those files to `www-data` run `sudo files_chown [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change ownership to `www-data:www-data`

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
