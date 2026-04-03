from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model, update_session_auth_hash
from accounts.services.email_service import send_otp_email

# IMPORTANT : Assure-toi d'avoir bien ajouté ces 4 nouveaux serializers dans serializers/auth.py
from accounts.serializers.auth import (
    RegisterSerializer, 
    VerifyOTPSerializer,
    ForgotPasswordSerializer,
    ResetPasswordConfirmSerializer,
    ChangePasswordSerializer,
    LogoutSerializer
)

User = get_user_model()

def get_tokens_for_user(user):
    """Génère l'Access Token (JWT) pour l'utilisateur"""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

class RegisterView(generics.CreateAPIView):
    """Inscription de l'utilisateur et génération de l'OTP"""
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        otp = user.generate_otp()
        send_otp_email(user, otp, "emails/otp_email.html", "Code OTP")
        
        return Response({
            "message": "Compte créé ! Vérifiez vos emails pour récupérer votre code à 6 chiffres."
        }, status=status.HTTP_201_CREATED)

class VerifyOTPView(generics.GenericAPIView):
    """Vérifie le code OTP et connecte l'utilisateur en lui donnant son Token"""
    serializer_class = VerifyOTPSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data['email']
        otp_code = serializer.validated_data['otp_code']

        try:
            user = User.objects.get(email=email)
            if user.otp_code == otp_code:
                user.is_email_verified = True
                user.otp_code = None 
                user.save()
                tokens = get_tokens_for_user(user)
                return Response({"message": "Email vérifié !", "tokens": tokens}, status=status.HTTP_200_OK)
            return Response({"error": "Code OTP incorrect."}, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({"error": "Utilisateur introuvable."}, status=status.HTTP_404_NOT_FOUND)

class ForgotPasswordView(generics.GenericAPIView):
    """L'utilisateur demande une réinitialisation via son email"""
    serializer_class = ForgotPasswordSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data["email"]
        
        try:
            user = User.objects.get(email=email)
            otp = user.generate_otp()
            send_otp_email(user, otp, "emails/reset_password.html", "Réinitialisation mot de passe")
            return Response({"message": "Un code de récupération a été envoyé à votre adresse email."}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"message": "Si cet email existe, un code de récupération a été envoyé."}, status=status.HTTP_200_OK)

class ResetPasswordConfirmView(generics.GenericAPIView):
    """L'utilisateur soumet le code OTP et son nouveau mot de passe"""
    serializer_class = ResetPasswordConfirmSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data["email"]
        otp_code = serializer.validated_data["otp_code"]
        new_password = serializer.validated_data["new_password"]

        try:
            user = User.objects.get(email=email, otp_code=otp_code)
            user.set_password(new_password)
            user.otp_code = None 
            user.save()
            return Response({"message": "Votre mot de passe a été réinitialisé avec succès."}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "Code OTP ou email invalide."}, status=status.HTTP_400_BAD_REQUEST)

class ChangePasswordView(generics.GenericAPIView):
    """Change le mot de passe depuis le profil (Utilisateur connecté)"""
    permission_classes = [IsAuthenticated]
    serializer_class = ChangePasswordSerializer

    def put(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user = request.user
        old_password = serializer.validated_data["old_password"]
        new_password = serializer.validated_data["new_password"]

        if not user.check_password(old_password):
            return Response({"error": "Ancien mot de passe incorrect."}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save()
        update_session_auth_hash(request, user) 
        return Response({"message": "Mot de passe mis à jour avec succès."}, status=status.HTTP_200_OK)

class LogoutView(generics.GenericAPIView):
    """Déconnexion : On invalide le Refresh Token (si Blacklist activé)"""
    permission_classes = [IsAuthenticated]
    serializer_class = LogoutSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            refresh_token = serializer.validated_data["refresh"]
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({"message": "Déconnexion réussie."}, status=status.HTTP_200_OK)
        except Exception:
            return Response({"error": "Erreur lors de la déconnexion ou token invalide."}, status=status.HTTP_400_BAD_REQUEST)