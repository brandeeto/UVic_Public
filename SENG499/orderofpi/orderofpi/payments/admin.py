from django.contrib import admin
from .models import Transaction
from django.conf import settings
import stripe

def refund_transaction(modeladmin, request, queryset):

    stripe.api_key = settings.STRIPE_TEST_SECRET_API_KEY

    for item in queryset:

        refund = stripe.Refund.create(
            charge=item.stripe_id
        )

        if refund['status'] == 'succeeded':
            newStatus = 'refunded'
        else:
            newStatus = refund['status']

        item.status=newStatus
        item.save()


refund_transaction.short_description = "Refund the selected Transactions"

class TransactionAdmin(admin.ModelAdmin):
    list_display = ['contract', 'status']
    ordering = ['contract']
    actions = [refund_transaction]
    readonly_fields=['status']

admin.site.register(Transaction, TransactionAdmin)