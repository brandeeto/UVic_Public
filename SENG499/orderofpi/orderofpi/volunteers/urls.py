from django.conf.urls import url
from django.views.generic import TemplateView

from . import views as volunteer_views

urlpatterns = [
    url(r'^assign/$', volunteer_views.assign, name='assign'),
    url(r'^signup/$', volunteer_views.sign_up, name='volunteer_signup'),
    url(r'^joined/$', TemplateView.as_view(template_name="volunteers/volunteer_joined.html"), name="volunteer_joined"),
    url(r'^schedule/$', volunteer_views.view_schedule, name='view_schedule'),
]