from django.shortcuts import render
from contracts.models import Contract

# Views for base order of pi pages, depending on the logic in these... might be able to get away with just these being rendered in the urls section


# View for the homepage
def home(request):
    template = "orderofpi/home.html"
    context = {'CommitedDonationTotal': Contract.GetCommitedDonationTotal()}
    #import sys
    #print('CommitedDonationSum = ' + str(Contract.GetCommitedDonationTotal()),sys.stderr)
    return render(request, template, context)


# View for the about page
def about(request):
    template = "orderofpi/about.html"
    context = {}
    return render(request, template, context)


# View for the rules page
def rules(request):
    template = "orderofpi/rules.html"
    context = {}
    return render(request, template, context)


# View for the rules page
def ranks(request):
    template = "orderofpi/ranks.html"
    context = {}
    return render(request, template, context)