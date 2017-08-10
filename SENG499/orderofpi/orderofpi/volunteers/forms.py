from django.forms import DateInput, ModelForm
from django.utils.translation import ugettext_lazy as _
from .models import Volunteer


# Contract form
class VolunteerForm(ModelForm):

    class Meta:
        model = Volunteer
        fields = ['name', 'email', 'phone_carrier', 'phone', 'executioner', 'pie_bearer', 'bard', 'inquisitor', 'counselor', 'undertaker']