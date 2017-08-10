from django.http import HttpResponseRedirect
from django.shortcuts import render, reverse
from .forms import VolunteerForm
from orderofpi.emails import Mailer


# Assign volunteer view
def assign(request):
    template = "volunteers/assign.html"
    context = {}
    return render(request, template, context)


# Assign volunteer view
def sign_up(request):
    template = "volunteers/sign_up.html"

    volunteer_form = VolunteerForm(request.POST or None)

    if volunteer_form.is_valid():
        volunteer_form.save()

        Mailer.send_html_email(
            plaintext_file='volunteers/thanks_email.txt', 
            htmly_file='volunteers/thanks_email.html',
            subject='Thanks for Signing up',
            to_name=volunteer_form.cleaned_data['name'], 
            to_email=volunteer_form.cleaned_data['email'] 
        )

 
        # TODO: Need to send out an email out here
        # TODO: Need to associate available times

        return HttpResponseRedirect(reverse('volunteer_joined'))

    context = {
        'volunteer_form': volunteer_form,
    }

    return render(request, template, context)


# Assign volunteer view
def view_schedule(request):
    template = "volunteers/view_schedule.html"
    context = {}
    return render(request, template, context)