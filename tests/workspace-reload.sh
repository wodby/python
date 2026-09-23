#!/bin/bash
set -euo pipefail
image="${IMAGE:?Set IMAGE to the candidate development image}"
volume=workspace-python-reload-$$
server=workspace-python-reload-$$
cleanup() { docker rm -f "$server" >/dev/null 2>&1 || true; docker volume rm "$volume" >/dev/null; }
trap cleanup EXIT
docker volume create "$volume" >/dev/null
docker run --rm --user 0 --entrypoint sh -v "$volume:/fixture" "$image" -ec 'chown 1000:1000 /fixture'
docker run --rm --entrypoint sh -e APP_ROOT=/fixture -v "$volume:/fixture" "$image" -ec '
cd /fixture
git init -q
printf "[project]\nname = \"workspace-test\"\nversion = \"0.1.0\"\nrequires-python = \">=3.10\"\ndependencies = [\"gunicorn==23.0.0\"]\n" > pyproject.toml
uv lock
cp uv.lock /tmp/expected.lock
workspace-python prepare
cmp uv.lock /tmp/expected.lock
printf "def app(environ, start_response):\n    start_response(\"200 OK\", [(\"Content-Type\", \"text/plain\")])\n    return [b\"before\"]\n" > app.py
'
docker run -d --name "$server" --network none -e WODBY_WORKSPACE=1 -e GUNICORN_APP=app:app -e APP_ROOT=/fixture -v "$volume:/fixture" "$image" >/dev/null
before=0
for i in $(seq 1 30); do if docker exec "$server" curl -fs http://localhost:8080/ | grep -q before; then before=1;break;fi;sleep 1;done
[ "$before" = 1 ] || { docker logs "$server";exit 1; }
docker run --rm --network none --entrypoint sh -v "$volume:/fixture" "$image" -ec "sed -i 's/before/after-edit/' /fixture/app.py"
after=0
for i in $(seq 1 30); do if docker exec "$server" curl -fs http://localhost:8080/ | grep -q after-edit; then after=1;break;fi;sleep 1;done
[ "$after" = 1 ] || { docker logs "$server";exit 1; }
echo 'Locked uv preparation and second-container Gunicorn polling reload passed'
