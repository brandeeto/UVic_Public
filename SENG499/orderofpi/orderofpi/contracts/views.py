# -*- coding: utf-8 -*-

from django.contrib import messages
from django.http import HttpResponseRedirect
from django.shortcuts import render, reverse, redirect

from .forms import ContractForm, ContractLookUpForm
from .models import Contract
from orderofpi.emails import Mailer


# Create contract view
def create_contract(request):
    template = "contracts/create_contract.html"

    contract_form = ContractForm(request.POST or None)

    if contract_form.is_valid():
        contract = contract_form.save()

        #email issuer
        Mailer.send_html_email(
            plaintext_file='contracts/thanks_email.txt', 
            htmly_file='contracts/thanks_email.html',
            subject='Contract Submission',
            to_name=contract_form.cleaned_data['issuer'], 
            to_email=contract_form.cleaned_data['issuer_email'] 
        )
        #notify organizers of new contract
        Mailer.send_html_email(
            plaintext_file='contracts/new_contract_email.txt', 
            htmly_file='contracts/new_contract_email.html',
            subject='New Contract Subbmited',
            to_name='', 
            to_email='esschar@uvic.ca' 
        )
        

        return HttpResponseRedirect(reverse('payments:online_payment', kwargs={'contract_id': contract.id}))

    context = {
        'contract_form': contract_form,
    }

    return render(request, template, context)


# Extend contract (Add money to existing contract)
def contract_lookup(request):
    template = "contracts/contract_lookup.html"

    contract_form = ContractLookUpForm(request.POST or None)

    if contract_form.is_valid():
        extend_id = contract_form.cleaned_data['extend_id']

        try:
            contract = Contract.objects.get(extend_id=extend_id)
            return redirect("payments:extend_contract", contract_id=contract.id)
        except Contract.DoesNotExist:
            messages.error(request, "Sorry, we couldn't find '" + extend_id + "' ¯\_(ツ)_/¯")
            return redirect(reverse("contract_lookup"))


    context = {
        "form": contract_form,
    }
    return render(request, template, context)
