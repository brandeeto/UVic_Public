from django import forms
from django.contrib.auth.forms import AuthenticationForm as DjangoAuthenticationForm


class AuthenticationForm(DjangoAuthenticationForm):
    username = forms.CharField(max_length=254)
