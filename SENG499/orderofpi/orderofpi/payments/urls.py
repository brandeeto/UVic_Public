from django.conf.urls import url

from . import views as payment_views

urlpatterns = [
    url(r'^pay/(?P<contract_id>\d+)$', payment_views.online_payment, name='online_payment'),
    url(r'^extend/(?P<contract_id>\d+)$', payment_views.extend_contract, name='extend_contract'),
    url(r'^checkout/$', payment_views.checkout, name='checkout'),
    url(r'^later/$', payment_views.pay_later, name='pay_later'),

]

