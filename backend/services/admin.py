from django.contrib import admin
from .models import Service, Helper, Booking

@admin.register(Service)
class ServiceAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']

@admin.register(Helper)
class HelperAdmin(admin.ModelAdmin):
    list_display = ['user', 'service', 'price', 'location', 'rating']

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['user', 'helper', 'date', 'status', 'created_at']
    list_filter = ['status']
