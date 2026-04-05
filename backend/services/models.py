from django.db import models
from accounts.models import User

class Service(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name

class Helper(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='helper_profile')
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='helpers')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    location = models.CharField(max_length=255)
    rating = models.FloatField(default=0.0)

    def __str__(self):
        return f"{self.user.username} - {self.service.name}"

class Booking(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
        ('completed', 'Completed'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    helper = models.ForeignKey(Helper, on_delete=models.CASCADE, related_name='received_bookings')
    date = models.DateTimeField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} -> {self.helper.user.username} ({self.status})"
