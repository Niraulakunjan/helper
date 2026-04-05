from rest_framework import serializers
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from services.models import Service, Helper, Booking
from chat.models import Message

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone', 'password', 'role']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            phone=validated_data.get('phone', ''),
            role=validated_data.get('role', 'user'),
        )
        return user


class UserSerializer(serializers.ModelSerializer):
    has_helper_profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone', 'role', 'has_helper_profile']

    def get_has_helper_profile(self, obj):
        try:
            return obj.helper_profile is not None
        except (AttributeError, User.helper_profile.RelatedObjectDoesNotExist):
            return False


class ServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Service
        fields = '__all__'


class HelperSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    service = ServiceSerializer(read_only=True)
    service_id = serializers.PrimaryKeyRelatedField(
        queryset=Service.objects.all(), source='service', write_only=True
    )

    class Meta:
        model = Helper
        fields = ['id', 'user', 'service', 'service_id', 'price', 'location', 'rating']


class BookingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    helper = HelperSerializer(read_only=True)
    helper_id = serializers.PrimaryKeyRelatedField(
        queryset=Helper.objects.all(), source='helper', write_only=True
    )

    class Meta:
        model = Booking
        fields = ['id', 'user', 'helper', 'helper_id', 'date', 'status', 'created_at']
        read_only_fields = ['status', 'created_at']


class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    receiver = UserSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'sender', 'receiver', 'content', 'timestamp', 'is_read']
