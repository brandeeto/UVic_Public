from django.db import models
from payments.models import Transaction
        

# Contract model. Used for...
class Contract(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('completed', 'Completed'),
        ('rejected', 'Rejected'),
    )

    target = models.CharField(max_length=30)
    issuer = models.CharField(max_length=30)
    issuer_email = models.EmailField()
    indicated_value = models.DecimalField(max_digits=10, decimal_places=2)
    issued_date = models.DateField(auto_now_add=True)
    charges = models.TextField()
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='pending')

        # If the contract allows funds to be added using an extension id
    extend_id = models.CharField(max_length=60, blank=True)

    # OoP Trial information
    trial_date = models.DateTimeField()
    trial_location = models.CharField(max_length=30)

    def __str__(self):
        return self.issuer + " is charging " + self.target + " $" + str(self.indicated_value) + " on the date of " + str(self.trial_date)

    @classmethod
    def GetCommitedDonationTotal(self):
        return Contract.objects.filter(
                models.Q(status='approved')
                |models.Q(status='completed')
                ).aggregate(models.Sum('indicated_value'))['indicated_value__sum']
        
    def GetActualDonationTotal(self):
        #to-do, trickier as this requires a mapping of the many-to-one relationship with 
        pass

    def GetActualDonation(self):
        return self.transaction_set.all().aggregate(models.Sum('amount'))['amount__sum']
        
# Contract notes model. Extension of the contract
class ContractNotes(models.Model):

    class Meta:
        verbose_name_plural = "contract notes"

    contract = models.ForeignKey(Contract, on_delete=models.CASCADE)
    author = models.CharField(max_length=30)
    text = models.TextField()

    def __str__(self):
        return "Notes by " + self.author + " on " + self.contract.__str__()
