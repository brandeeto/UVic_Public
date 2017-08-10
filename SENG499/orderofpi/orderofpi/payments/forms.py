from django import forms
from django.utils.translation import ugettext_lazy as _
from .models import Transaction


# Contract form
class ExtendContractExtensionForm(forms.Form):
    amount = forms.DecimalField(max_digits=10, decimal_places=2, min_value=5)


    def __init__(self, *args, **kwargs):
        super(ExtendContractExtensionForm, self).__init__(*args, **kwargs)

        self.fields['amount'].widget.attrs['placeholder'] = 'Min. $5.00'
