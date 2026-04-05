from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate, get_user_model
from django.db.models import Q
from services.models import Service, Helper, Booking
from chat.models import Message
from .serializers import (
    RegisterSerializer, UserSerializer, ServiceSerializer,
    HelperSerializer, BookingSerializer, MessageSerializer
)

User = get_user_model()


# --- Auth ---
class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(username=username, password=password)
        if user:
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user': UserSerializer(user).data,
            })
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


# --- Services ---
class ServiceListView(generics.ListAPIView):
    queryset = Service.objects.all()
    serializer_class = ServiceSerializer
    permission_classes = [permissions.AllowAny]


class HelperListView(generics.ListAPIView):
    serializer_class = HelperSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        qs = Helper.objects.select_related('user', 'service')
        service_id = self.request.query_params.get('service_id')
        location = self.request.query_params.get('location')
        if service_id:
            qs = qs.filter(service_id=service_id)
        if location:
            qs = qs.filter(location__icontains=location)
        return qs


class HelperDetailView(generics.RetrieveAPIView):
    queryset = Helper.objects.all()
    serializer_class = HelperSerializer
    permission_classes = [permissions.AllowAny]


class RegisterHelperView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        user.role = 'helper'
        user.save()
        data = request.data.copy()
        serializer = HelperSerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# --- Bookings ---
class BookingCreateView(generics.CreateAPIView):
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class MyBookingsView(generics.ListAPIView):
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'helper':
            try:
                return Booking.objects.filter(helper=user.helper_profile)
            except Helper.DoesNotExist:
                return Booking.objects.none()
        return Booking.objects.filter(user=user)


class BookingStatusUpdateView(generics.UpdateAPIView):
    queryset = Booking.objects.all()
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def partial_update(self, request, *args, **kwargs):
        booking = self.get_object()
        new_status = request.data.get('status')
        if new_status not in ['accepted', 'rejected', 'completed']:
            return Response({'error': 'Invalid status'}, status=status.HTTP_400_BAD_REQUEST)
        booking.status = new_status
        booking.save()
        return Response(BookingSerializer(booking).data)


# --- Chat ---
class ChatHistoryView(generics.ListAPIView):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        other_id = self.kwargs['other_id']
        user = self.request.user
        return Message.objects.filter(
            Q(sender=user, receiver_id=other_id) |
            Q(sender_id=other_id, receiver=user)
        ).order_by('timestamp')
