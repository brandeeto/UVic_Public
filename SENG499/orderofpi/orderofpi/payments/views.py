from django.shortcuts import render, get_object_or_404, reverse
from django.conf import settings
from django.contrib import messages
from django.http import HttpResponseRedirect
from contracts.models import Contract

from .models import Transaction
from .forms import ExtendContractExtensionForm

from datetime import datetime
import stripe


# Create your views here.
def online_payment(request, contract_id):
    template = "payments/online_payment.html"

    contract = get_object_or_404(Contract , id=contract_id)

    context = {
        'contract': contract,
        'indicated_value': contract.indicated_value * 100,
        'stripe_key': settings.STRIPE_TEST_API_KEY,
        'contract_id':contract.id
    }
    return render(request, template, context)


# Extend contract (Add money to existing contract)
def extend_contract(request, contract_id):
    template = "payments/extend_contract.html"

    contract = get_object_or_404(Contract, id=contract_id)
    extend_form = ExtendContractExtensionForm(None)

    donation_total = 0
    transaction_set = contract.transaction_set.all()

    if len(transaction_set) == 0:
        donation_total = contract.indicated_value
    else:
        for transaction in transaction_set:
            donation_total += transaction.amount


    context = {
        "donation_total": donation_total,
        "contract": contract,
        "form": extend_form,
        'stripe_key': settings.STRIPE_TEST_API_KEY,
        'contract_id': contract.id
    }
    return render(request, template, context)


def checkout(request):

    contract = get_object_or_404(Contract, id=request.POST['contract_id'])
    stripe.api_key = settings.STRIPE_TEST_SECRET_API_KEY
    token = request.POST['stripeToken']

    # This amount will handle whether the user is extending the transaction
    extend_amount = request.POST.get('amount', "")

    # Original contract
    if extend_amount == "":
        amount = contract.indicated_value
    # Existing contract
    else:
        amount = float(extend_amount)

    try:
        charge = stripe.Charge.create(
            amount=int(amount * 100),
            currency="cad",
            source=token,  # obtained with Stripe.js
            description="Donation",
            receipt_email=request.POST['stripeEmail']
        )

    except stripe.error.CardError as e:
        template = "payments/pay_later.html"
        context = {"text": "There was an error with the card please contact the Glorious Order of Pi at 250-721-8822 or come to the ESS Office at UVic "}

        return render(request, template, context)

    except Exception as e:
        # Something else happened, completely unrelated to Stripe
        template = "payments/pay_later.html"
        context = {"text": "Something went wrong, please contact the Glorious Order of Pi at 250-721-8822 or come to the ESS Office at UVic "}

        return render(request, template, context)

    payment = Transaction(
        contract=contract,
        type='online_cc',
        amount=contract.indicated_value,
        email=request.POST['stripeEmail'],
        stripe_id=charge['id'],
        status=charge['status'],
        date=datetime.now()
    )
    payment.save()

    messages.success(request, 'Payment Successful, Thank you!')
    return HttpResponseRedirect(reverse('sent_contract'))


def pay_later(request):
    template = "payments/pay_later.html"
    context = { "text": "Contract Saved! To pay come into the ESS before the trial date."}

    return render(request, template, context)