import os

from django.http import HttpResponse
from django.urls import path


def secret_key(_request):
    """Expose the worker environment only inside the disposable test app."""
    return HttpResponse(os.environ["DJANGO_SECRET_KEY"], content_type="text/plain")


urlpatterns = [
    path("_test/secret-key", secret_key),
]
