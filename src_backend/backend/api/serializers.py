from rest_framework import serializers
from django.contrib.auth.models import User
from core.models import (
    UserProfile, Product, Favorite, ProductView,
    SearchHistory, TrendAlert, ScrapingJob
)


class UserSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'name']
        read_only_fields = ['id']
    
    def get_name(self, obj):
        """Return full name or username"""
        if obj.first_name and obj.last_name:
            return f"{obj.first_name} {obj.last_name}"
        elif obj.first_name:
            return obj.first_name
        return obj.username
    
    def update(self, instance, validated_data):
        """Handle name field update"""
        # If 'name' is in the request data (not in validated_data as it's read-only)
        name = self.context.get('request').data.get('name') if self.context.get('request') else None
        
        if name:
            # Split name into first_name and last_name
            name_parts = name.strip().split(' ', 1)
            instance.first_name = name_parts[0]
            instance.last_name = name_parts[1] if len(name_parts) > 1 else ''
        
        # Update email if provided
        if 'email' in validated_data:
            instance.email = validated_data['email']
        
        instance.save()
        return instance


class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    favorite_count = serializers.IntegerField(read_only=True)
    view_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = UserProfile
        fields = [
            'id', 'user', 'avatar', 'subscription_plan',
            'subscription_expiry_date', 'profitability_score',
            'notifications_enabled', 'favorite_count', 'view_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'profitability_score']


class ProductSerializer(serializers.ModelSerializer):
    performance_metrics = serializers.ReadOnlyField()
    supplier = serializers.ReadOnlyField()
    is_favorite = serializers.SerializerMethodField()
    
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'source', 'source_url',
            'category', 'price', 'cost', 'profit', 'image_url',
            'images', 'available_colors', 'score', 'demand_level',
            'popularity', 'competition', 'profitability',
            'trend_percentage', 'is_trending', 'supplier_name',
            'supplier_rating', 'supplier_review_count',
            'performance_metrics', 'supplier', 'is_favorite',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'score', 'demand_level', 'popularity',
            'competition', 'profitability', 'is_trending',
            'created_at', 'updated_at'
        ]
    
    def get_is_favorite(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Favorite.objects.filter(user=request.user, product=obj).exists()
        return False


class ProductListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for product lists"""
    is_favorite = serializers.SerializerMethodField()
    
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'category', 'price', 'profit',
            'image_url', 'score', 'trend_percentage',
            'is_trending', 'is_favorite', 'source'
        ]
    
    def get_is_favorite(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Favorite.objects.filter(user=request.user, product=obj).exists()
        return False


class FavoriteSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = Favorite
        fields = ['id', 'product', 'product_id', 'created_at']
        read_only_fields = ['id', 'created_at']
    
    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)


class ProductViewSerializer(serializers.ModelSerializer):
    product = ProductListSerializer(read_only=True)
    
    class Meta:
        model = ProductView
        fields = ['id', 'product', 'viewed_at']
        read_only_fields = ['id', 'viewed_at']


class SearchHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = SearchHistory
        fields = ['id', 'query', 'filters', 'results_count', 'created_at']
        read_only_fields = ['id', 'created_at']


class TrendAlertSerializer(serializers.ModelSerializer):
    product = ProductListSerializer(read_only=True)
    
    class Meta:
        model = TrendAlert
        fields = [
            'id', 'alert_type', 'title', 'message',
            'product', 'is_read', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class ScrapingJobSerializer(serializers.ModelSerializer):
    class Meta:
        model = ScrapingJob
        fields = [
            'id', 'source', 'category', 'status',
            'products_scraped', 'products_created',
            'products_updated', 'error_message',
            'started_at', 'completed_at', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    password_confirm = serializers.CharField(write_only=True, min_length=6)
    fullname = serializers.CharField(write_only=True, required=True)
    username = serializers.CharField(required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'fullname']
    
    def validate_email(self, value):
        """Ensure email is unique"""
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already registered")
        return value
    
    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Passwords do not match")
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        fullname = validated_data.pop('fullname')
        
        # Auto-generate username from email if not provided
        username = validated_data.get('username', '').strip()
        if not username:
            email = validated_data['email']
            username = email.split('@')[0]
            # Ensure username is unique
            base_username = username
            counter = 1
            while User.objects.filter(username=username).exists():
                username = f"{base_username}{counter}"
                counter += 1
        
        validated_data['username'] = username
        
        # Split fullname into first_name and last_name
        name_parts = fullname.strip().split(' ', 1)
        validated_data['first_name'] = name_parts[0]
        validated_data['last_name'] = name_parts[1] if len(name_parts) > 1 else ''
        
        user = User.objects.create_user(**validated_data)
        
        # Create user profile
        UserProfile.objects.create(user=user)
        
        return user


class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, min_length=6)
    new_password_confirm = serializers.CharField(required=True, min_length=6)
    
    def validate(self, data):
        if data['new_password'] != data['new_password_confirm']:
            raise serializers.ValidationError("New passwords do not match")
        return data


class ProductAnalysisSerializer(serializers.Serializer):
    """Serializer for AI product analysis results"""
    scores = serializers.DictField()
    insights = serializers.ListField()
    recommendations = serializers.ListField()
    risk_level = serializers.CharField()
    is_recommended = serializers.BooleanField()

class ProductImportSerializer(serializers.Serializer):
    url = serializers.URLField(required=True)


class EmailOTPSerializer(serializers.Serializer):
    """Serializer for sending OTP to email"""
    email = serializers.EmailField(required=True)


class OTPVerificationSerializer(serializers.Serializer):
    """Serializer for verifying OTP code"""
    email = serializers.EmailField(required=True)
    otp_code = serializers.CharField(max_length=6, min_length=6, required=True)
    
    def validate_otp_code(self, value):
        """Validate that OTP code contains only digits"""
        if not value.isdigit():
            raise serializers.ValidationError("OTP code must contain only digits")
        return value


class OTPResendSerializer(serializers.Serializer):
    """Serializer for resending OTP"""
    email = serializers.EmailField(required=True)


class RegisterWithOTPSerializer(serializers.ModelSerializer):
    """Register user with email and OTP verification"""
    password_confirm = serializers.CharField(write_only=True)
    otp_code = serializers.CharField(max_length=6, min_length=6, required=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'first_name', 'last_name', 'otp_code']
        extra_kwargs = {
            'password': {'write_only': True},
            'first_name': {'required': False},
            'last_name': {'required': False},
        }
    
    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password": "Passwords do not match"})
        
        # Check if OTP is verified for this email
        from core.models import EmailOTP
        from django.utils import timezone
        
        email = data.get('email')
        otp_code = data.get('otp_code')
        
        try:
            otp = EmailOTP.objects.get(email=email, otp_code=otp_code)
            
            if not otp.is_verified:
                raise serializers.ValidationError({"otp_code": "Please verify your OTP first"})
            
            if otp.is_expired:
                raise serializers.ValidationError({"otp_code": "OTP has expired"})
        except EmailOTP.DoesNotExist:
            raise serializers.ValidationError({"otp_code": "Invalid OTP code"})
        
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        validated_data.pop('otp_code')
        
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        return user


class GoogleAuthSerializer(serializers.Serializer):
    """Serializer for Google OAuth token verification"""
    access_token = serializers.CharField(required=True)
    id_token = serializers.CharField(required=False, allow_blank=True)
    
    def validate(self, data):
        """Validate Google token"""
        access_token = data.get('access_token')
        
        if not access_token:
            raise serializers.ValidationError({"access_token": "This field is required"})
        
        return data


class GoogleLoginSerializer(serializers.Serializer):
    """Response serializer for Google login"""
    user = UserSerializer(read_only=True)
    token = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)
    message = serializers.CharField(read_only=True)
