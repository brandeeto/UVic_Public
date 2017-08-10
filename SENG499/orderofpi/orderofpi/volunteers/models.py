from django.db import models


# Volunteer Model
class Volunteer(models.Model):
    name = models.CharField(max_length=30)
    date = models.DateField(auto_now_add=True)
    email = models.EmailField()

    # Phone information, we need it to send freeee texts
    # List is under Canada, taken from ~~~~ https://martinfitzpatrick.name/list-of-email-to-sms-gateways/ ~~~~~
    # The Database will combine the phone number field and carrier as such: number@emailtxtgateway
    CARRIER_CHOICES = (
        ('@sms.wirefree.informe.ca', 'Aliant'),
        ('@txt.bellmobility.ca', 'Bell Mobility'),
        ('@sms.fido.ca', 'Fido'),
        ('@msg.telus.com', 'Telus'),
        ('@sms.lynxmobility.com', 'Lynx Mobility'),
        ('@text.mtsmobility.com', 'MTS Mobility'),
        ('@mobiletxt.ca', 'PC Telecom'),
        ('@sms.sasktel.com', 'SaskTel'),
        ('@vmobile.ca', 'Virgin Mobile'),
        ('@t.westnet.ca', 'Westnet'),
        ('@txt.windmobile.ca', 'Wind Mobile'),
        ('@sms.rogers.com', 'Rogers Wireless'),
        ('@msg.telus.com', 'Telus Mobility'),
    )
    phone_carrier = models.CharField(max_length=30, choices=CARRIER_CHOICES, blank=True)
    phone = models.CharField(max_length=15)

    # Volunteer positions
    executioner = models.BooleanField(default=False)
    pie_bearer = models.BooleanField(default=False)
    bard = models.BooleanField(default=False)
    inquisitor = models.BooleanField(default=False)
    counselor = models.BooleanField(default=False)
    undertaker = models.BooleanField(default=False)


    def __str__(self):
        return self.name


# Volunteer availablity
class VolunteerAvailability(models.Model):
    volunteer = models.ForeignKey(Volunteer, on_delete=models.CASCADE)
    day = models.IntegerField()
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()


# Volunteer Assignment
class VolunteerAssignment(models.Model):
    volunteer = models.ForeignKey(Volunteer, on_delete=models.CASCADE)
    start_time = models.DateTimeField()

    # Role selection
    ROLE_CHOICES = (
        ('executioner', 'Executioner'),
        ('pie_bearer', 'Pie Bearer'),
        ('bard', 'Bard'),
        ('inquisitor', 'Inquisitor'),
        ('counselor', 'Counselor'),
        ('undertaker', 'Undertaker'),
    )
    role = models.CharField(max_length=15, choices=ROLE_CHOICES)
