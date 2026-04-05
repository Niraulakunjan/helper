from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from accounts.views import (
    RegisterView, LoginView, ProfileView,
    ServiceListView, HelperListView, HelperDetailView, RegisterHelperView,
    BookingCreateView, MyBookingsView, BookingStatusUpdateView,
    ChatHistoryView, SendMessageView, ConversationListView,
)

urlpatterns = [
    path('admin/', admin.site.urls),

    # Auth
    path('api/auth/register/', RegisterView.as_view(), name='register'),
    path('api/auth/login/', LoginView.as_view(), name='login'),
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/auth/profile/', ProfileView.as_view(), name='profile'),

    # Services & Helpers
    path('api/services/', ServiceListView.as_view(), name='services'),
    path('api/helpers/', HelperListView.as_view(), name='helpers'),
    path('api/helpers/<int:pk>/', HelperDetailView.as_view(), name='helper-detail'),
    path('api/helpers/register/', RegisterHelperView.as_view(), name='helper-register'),

    # Bookings
    path('api/bookings/', BookingCreateView.as_view(), name='booking-create'),
    path('api/bookings/mine/', MyBookingsView.as_view(), name='my-bookings'),
    path('api/bookings/<int:pk>/status/', BookingStatusUpdateView.as_view(), name='booking-status'),

    # Chat — order matters: specific paths before parameterised ones
    path('api/chat/conversations/', ConversationListView.as_view(), name='chat-conversations'),
    path('api/chat/<int:other_id>/', ChatHistoryView.as_view(), name='chat-history'),
    path('api/chat/<int:other_id>/send/', SendMessageView.as_view(), name='chat-send'),
]
