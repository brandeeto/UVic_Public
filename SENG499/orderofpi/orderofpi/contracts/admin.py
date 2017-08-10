from django.contrib import admin
from django.shortcuts import render

from .models import Contract, ContractNotes

def print_contract(modeladmin, request, queryset):

    template = "contracts/print_contract.html"

    if queryset.count() != 1:
        modeladmin.message_user(request, "Can not print more than one contract at a time.")
        return

    for item in queryset:
        contract = item

    context = {
        'contract_info': contract,
    }

    return render(request, template, context)

print_contract.short_description = "Print contract for the trial."

class ContractNotesInline(admin.TabularInline):
    model = ContractNotes
    extra = 1
    fields = ['contract', 'author', 'text']


class ContractAdmin(admin.ModelAdmin):
    inlines = [ContractNotesInline]
    list_display = ['target', 'issuer', 'trial_date', 'trial_location', 'status', 'indicated_value', 'actual_value']
    readonly_fields = ['actual_value']
    actions = [print_contract]

    def actual_value(self,obj):
        return obj.GetActualDonation()

admin.site.register(Contract, ContractAdmin)
admin.site.register(ContractNotes)
