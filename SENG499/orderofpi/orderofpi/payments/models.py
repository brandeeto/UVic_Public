from django.db import models


# Transaction model
class Transaction(models.Model):
    contract = models.ForeignKey('contracts.Contract', on_delete=models.CASCADE)

    # Transaction basic details
    TYPE_CHOICES = (
        ('online_cc', 'Online Credit Card'),
        ('offline_cc', 'In Office Credit Card'),
        ('cash', 'Cash'),
    )

    STATUS_CHOICES = (
        ('succeeded', 'Succeeded'),
        ('pending', 'Pending'),
        ('failed', 'Failed'),
        ('cancelled', 'Cancelled'),
        ('refunded', 'Refunded'),
    )

    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(auto_now_add=True)
    email = models.EmailField()

    # Stripe attributes, can be empty due to cash transaction
    status = models.CharField(max_length=50, blank=True, choices=STATUS_CHOICES)
    stripe_id = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return self.get_type_display() + " charge for $" + str(self.amount) + " on the date of " + str(self.date)
