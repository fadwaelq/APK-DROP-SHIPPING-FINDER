import random
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema 
from django.contrib.auth import get_user_model, authenticate
from rest_framework.permissions import IsAuthenticated 

# --- NOUVEAUX IMPORTS POUR L'EMAIL ---
from django.core.mail import send_mail
from django.conf import settings

# On importe TOUS les traducteurs proprement
from .serializers import (
    RegisterSerializer, 
    VerifyOTPSerializer, 
    LoginSerializer, 
    ResendOTPSerializer,
    ForgotPasswordSerializer,
    ResetPasswordSerializer
)

User = get_user_model()

# --- API : INSCRIPTION ---
class RegisterView(APIView):
    serializer_class = RegisterSerializer
    @extend_schema(request=RegisterSerializer) 
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save() # L'envoi de l'email se fait déjà dans le serializer.create()
            refresh = RefreshToken.for_user(user)
            return Response({
                "confirmation": "Inscription réussie. Veuillez vérifier votre email pour le code OTP.",
                "access_token": str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ---  API : VERIFICATION OTP ---
class VerifyOTPView(APIView):
    serializer_class = VerifyOTPSerializer
    @extend_schema(request=VerifyOTPSerializer)
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            otp_code = serializer.validated_data['otp_code']
            
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return Response({"error": "Utilisateur non trouvé."}, status=status.HTTP_404_NOT_FOUND)
            
            if user.otp_code == otp_code:
                user.is_verified = True
                user.otp_code = "" 
                user.save()
                refresh = RefreshToken.for_user(user)
                return Response({
                    "user": {"email": user.email, "full_name": user.full_name, "is_verified": user.is_verified},
                    "access_token": str(refresh.access_token)
                }, status=status.HTTP_200_OK)
                
            return Response({"error": "Code OTP incorrect."}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ---  API : CONNEXION ---
class LoginView(APIView):
    serializer_class = LoginSerializer
    @extend_schema(request=LoginSerializer)
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            password = serializer.validated_data['password']
            
            user = authenticate(request, email=email, password=password)
            if user is not None:
                refresh = RefreshToken.for_user(user)
                return Response({
                    "user": {"email": user.email, "full_name": user.full_name, "is_verified": user.is_verified},
                    "access_token": str(refresh.access_token)
                }, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Email ou mot de passe incorrect."}, status=status.HTTP_401_UNAUTHORIZED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
# --- API : PROFIL UTILISATEUR ---
class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    # On ajoute ceci pour Swagger, même si c'est une APIView simple
    # Tu peux utiliser RegisterSerializer ou en créer un dédié (UserSerializer)
    serializer_class = RegisterSerializer 

    @extend_schema(responses={200: RegisterSerializer})
    def get(self, request):
        user = request.user
        return Response({
            "utilisateur": user.full_name,
            "email": user.email,
            "is_verified": user.is_verified
        }, status=status.HTTP_200_OK)
# --- API : RENVOI DU CODE OTP ---
class ResendOTPView(APIView):
    serializer_class = ResendOTPSerializer
    @extend_schema(request=ResendOTPSerializer)
    def post(self, request):
        serializer = ResendOTPSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            try:
                user = User.objects.get(email=email)
                user.otp_code = str(random.randint(100000, 999999))
                user.save()
                
                # --- ENVOI DU VRAI EMAIL ---
                try:
                    send_mail(
                        subject="Ton nouveau code de vérification",
                        message=f"Bonjour,\n\nVoici ton nouveau code OTP : {user.otp_code}",
                        from_email=settings.EMAIL_HOST_USER,
                        recipient_list=[user.email],
                        fail_silently=False,
                    )
                except Exception as e:
                    print(f" Erreur envoi email: {e}")
                
                return Response({
                    "confirmation": "Un nouveau code OTP a été envoyé."
                }, status=status.HTTP_200_OK)
            except User.DoesNotExist:
                return Response({"error": "Utilisateur non trouvé."}, status=status.HTTP_404_NOT_FOUND)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# --- API : DEMANDE MOT DE PASSE OUBLIÉ ---
class ForgotPasswordView(APIView):
    serializer_class = ForgotPasswordSerializer
    @extend_schema(request=ForgotPasswordSerializer)
    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            try:
                user = User.objects.get(email=email)
                reset_code = str(random.randint(100000, 999999))
                user.otp_code = reset_code 
                user.save()
                
                # --- ENVOI DU VRAI EMAIL ---
                try:
                    send_mail(
                        subject="Réinitialisation de ton mot de passe",
                        message=f"Voici ton code de récupération : {reset_code}",
                        from_email=settings.EMAIL_HOST_USER,
                        recipient_list=[user.email],
                        fail_silently=False,
                    )
                except Exception as e:
                    print(f"Erreur envoi email: {e}")
                
                return Response({
                    "confirmation": "Un email de réinitialisation a été envoyé."
                }, status=status.HTTP_200_OK)
                
            except User.DoesNotExist:
                return Response({
                    "confirmation": "Un email de réinitialisation a été envoyé."
                }, status=status.HTTP_200_OK)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# --- API : CRÉATION DU NOUVEAU MOT DE PASSE ---
class ResetPasswordView(APIView):
    serializer_class = ResetPasswordSerializer
    @extend_schema(request=ResetPasswordSerializer)
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            otp_code = serializer.validated_data['otp_code']
            new_password = serializer.validated_data['new_password']
            
            try:
                user = User.objects.get(email=email)
                if user.otp_code == otp_code:
                    user.set_password(new_password)
                    user.otp_code = "" 
                    user.save()
                    return Response({"message": "Mot de passe réinitialisé."}, status=status.HTTP_200_OK)
                return Response({"error": "Code invalide."}, status=status.HTTP_400_BAD_REQUEST)
            except User.DoesNotExist:
                return Response({"error": "Utilisateur non trouvé."}, status=status.HTTP_404_NOT_FOUND)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)