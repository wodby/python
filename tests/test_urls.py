import os

from django.http import HttpResponse
from django.urls import path


def index(_request):
    """Keep the fixture's root endpoint compatible with the readiness check."""
    return HttpResponse("Get started with Django\n", content_type="text/plain")


def secret_key(_request):
    """Expose the worker environment only inside the disposable test app."""
    return HttpResponse(os.environ["DJANGO_SECRET_KEY"], content_type="text/plain")


urlpatterns = [
    path("", index),
    path("_test/secret-key", secret_key),
]
