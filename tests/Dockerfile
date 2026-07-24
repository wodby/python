ARG IMAGE

FROM ${IMAGE}

COPY requirements.txt .

RUN pip install -r requirements.txt

RUN django-admin startproject myapp .

COPY test_urls.py myapp/urls.py

ENV GUNICORN_APP=myapp.wsgi:application
