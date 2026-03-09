import random
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema 
from django.contrib.auth import get_user_model, authenticate
from rest_framework.permissions import IsAuthenticated 
from django.core.mail import send_mail
from django.conf import settings

from .serializers import (
    RegisterSerializer, VerifyOTPSerializer, LoginSerializer, 
    ResendOTPSerializer, ForgotPasswordSerializer, ResetPasswordSerializer
)

User = get_user_model()

# --- FONCTION UTILITAIRE (Pour éviter de répéter le code) ---
def generate_and_send_otp(user, subject, message_prefix):
    """Génère un OTP, le sauvegarde et l'envoie par email."""
    otp_code = str(random.randint(100000, 999999))
    user.otp_code = otp_code
    user.save()
    
    try:
        send_mail(
            subject=subject,
            message=f"{message_prefix} : {otp_code}",
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[user.email],
            fail_silently=False,
        )
    except Exception as e:
        print(f"Erreur envoi email: {e}")

# --- API VIEWS ---

class RegisterView(APIView):
    @extend_schema(request=RegisterSerializer) 
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save() 
            refresh = RefreshToken.for_user(user)
            return Response({
                "confirmation": "Inscription réussie. Vérifiez votre email.",
                "access_token": str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class VerifyOTPView(APIView):
    @extend_schema(request=VerifyOTPSerializer)
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        if serializer.is_valid():
            try:
                user = User.objects.get(email=serializer.validated_data['email'])
                if user.otp_code == serializer.validated_data['otp_code']:
                    user.is_verified = True
                    user.otp_code = "" # On vide le code après usage
                    user.save()
                    refresh = RefreshToken.for_user(user)
                    return Response({
                        "user": {"email": user.email, "full_name": user.full_name, "is_verified": True},
                        "access_token": str(refresh.access_token)
                    }, status=status.HTTP_200_OK)
                return Response({"error": "Code OTP incorrect."}, status=status.HTTP_400_BAD_REQUEST)
            except User.DoesNotExist:
                return Response({"error": "Utilisateur non trouvé."}, status=status.HTTP_404_NOT_FOUND)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    @extend_schema(request=LoginSerializer)
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = authenticate(
                request, 
                email=serializer.validated_data['email'], 
                password=serializer.validated_data['password']
            )
            if user:
                refresh = RefreshToken.for_user(user)
                return Response({
                    "user": {"email": user.email, "full_name": user.full_name, "is_verified": user.is_verified},
                    "access_token": str(refresh.access_token)
                }, status=status.HTTP_200_OK)
            return Response({"error": "Email ou mot de passe incorrect."}, status=status.HTTP_401_UNAUTHORIZED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    @extend_schema(responses={200: RegisterSerializer})
    def get(self, request):
        return Response({
            "utilisateur": request.user.full_name,
            "email": request.user.email,
            "is_verified": request.user.is_verified
        }, status=status.HTTP_200_OK)


class ResendOTPView(APIView):
    @extend_schema(request=ResendOTPSerializer)
    def post(self, request):
        serializer = ResendOTPSerializer(data=request.data)
        if serializer.is_valid():
            try:
                user = User.objects.get(email=serializer.validated_data['email'])
                generate_and_send_otp(user, "Ton nouveau code de vérification", "Voici ton nouveau code OTP")
                return Response({"confirmation": "Un nouveau code OTP a été envoyé."}, status=status.HTTP_200_OK)
            except User.DoesNotExist:
                return Response({"error": "Utilisateur non trouvé."}, status=status.HTTP_404_NOT_FOUND)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ForgotPasswordView(APIView):
    @extend_schema(request=ForgotPasswordSerializer)
    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            try:
                user = User.objects.get(email=serializer.validated_data['email'])
                generate_and_send_otp(user, "Réinitialisation de ton mot de passe", "Voici ton code de récupération")
            except User.DoesNotExist:
                pass # Sécurité : on ne dit pas si l'email existe ou non aux hackers
            
            return Response({"confirmation": "Un email de réinitialisation a été envoyé."}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ResetPasswordView(APIView):
    @extend_schema(request=ResetPasswordSerializer)
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            try:
                user = User.objects.get(email=serializer.validated_data['email'])
                if user.otp_code == serializer.validated_data['otp_code']:
                    user.set_password(serializer.validated_data['new_password'])
                    user.otp_code = "" 
                    user.save()
                    return Response({"message": "Mot de passe réinitialisé."}, status=status.HTTP_200_OK)
                return Response({"error": "Code invalide."}, status=status.HTTP_400_BAD_REQUEST)
            except User.DoesNotExist:
                return Response({"error": "Utilisateur non trouvé."}, status=status.HTTP_404_NOT_FOUND)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)