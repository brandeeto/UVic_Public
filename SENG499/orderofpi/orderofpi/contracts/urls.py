from django.conf.urls import url
from django.views.generic import TemplateView

from . import views as contract_views

urlpatterns = [
    url(r'^create/$', contract_views.create_contract, name='create_contract'),
    url(r'^find/$', contract_views.contract_lookup, name='contract_lookup'),
    url(r'^sent/$', TemplateView.as_view(template_name="contracts/sent_contract.html"), name='sent_contract'),
]