"""orderofpi URL Configuration"""

from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin
from django.contrib.auth import views as auth_views

from . import views as orderofpi_views
from .forms import AuthenticationForm

urlpatterns = [
    url(r'^$', orderofpi_views.home, name='home'),
    url(r'^about/$', orderofpi_views.about, name='about'),
    url(r'^rules/$', orderofpi_views.rules, name='rules'),
    url(r'^ranks/$', orderofpi_views.ranks, name='ranks'),
    url(r'^volunteer/', include('volunteers.urls')),
    url(r'^contract/', include('contracts.urls')),
    url(r'^payments/', include('payments.urls', namespace='payments')),
    url(r'^admin/', admin.site.urls),
    # Auth
    url(r'^login/$', auth_views.login,{'authentication_form': AuthenticationForm, 'template_name': 'registration/login.html'}, name='users-login'),
    url(r'^logout/$', auth_views.logout, {'next_page': settings.LOGIN_REDIRECT_URL}, name='users-logout'),
    # Third party
    url(r'^accounts/', include('registration.backends.simple.urls')),
]
