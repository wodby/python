# https://github.com/benoitc/gunicorn/blob/master/examples/example_config.py

bind = '127.0.0.1:8000'
backlog = {{ getenv "GUNICORN_BACKLOG" "2048" }}

workers = {{ getenv "GUNICORN_WORKERS" "4" }}
worker_class = '{{ getenv "GUNICORN_WORKER_CLASS" "sync" }}'
worker_connections = {{ getenv "GUNICORN_WORKER_CONNECTIONS" "1000" }}
timeout = {{ getenv "GUNICORN_TIMEOUT" "30" }}
keepalive = {{ getenv "GUNICORN_KEEPALIVE" "2" }}

spew = {{ getenv "GUNICORN_SPEW" "False" }}

daemon = False
raw_env = [
'DJANGO_SECRET_KEY=something',
'SPAM=eggs',
]
pidfile = None
umask = 0
user = {{ getenv "GUNICORN_USER" "www-data" }}
group = {{ getenv "GUNICORN_GROUP" "www-data" }}
tmp_upload_dir = None

errorlog = '-'
loglevel = '{{ getenv "GUNICORN_LOGLEVEL" "info" }}'
accesslog = '-'
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

proc_name = '{{ getenv "GUNICORN_PROC_NAME" "Gunicorn" }}'

def post_fork(server, worker):
server.log.info("Worker spawned (pid: %s)", worker.pid)

def pre_fork(server, worker):
pass

def pre_exec(server):
server.log.info("Forked child, re-executing.")

def when_ready(server):
server.log.info("Server is ready. Spawning workers")

def worker_int(worker):
worker.log.info("worker received INT or QUIT signal")

## get traceback info
import threading, sys, traceback
id2name = dict([(th.ident, th.name) for th in threading.enumerate()])
code = []
for threadId, stack in sys._current_frames().items():
code.append("\n# Thread: %s(%d)" % (id2name.get(threadId,""),
threadId))
for filename, lineno, name, line in traceback.extract_stack(stack):
code.append('File: "%s", line %d, in %s' % (filename,
lineno, name))
if line:
code.append("  %s" % (line.strip()))
worker.log.debug("\n".join(code))

def worker_abort(worker):
worker.log.info("worker received SIGABRT signal")