from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from accounts.serializers.auth import RegisterSerializer, VerifyOTPSerializer

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
        
        # Génération du code OTP
        otp = user.generate_otp()
        
        # TODO: Plus tard, on branchera SendGrid ou Amazon SES ici pour envoyer le vrai email.
        # Pour l'instant, on l'imprime dans la console de ton terminal pour que tu puisses tester !
        print(f"\n [SIMULATION EMAIL] - Votre code secret pour {user.email} est : {otp} \n")
        
        return Response({
            "message": "Compte créé ! Vérifiez vos emails pour récupérer votre code à 6 chiffres."
        }, status=status.HTTP_201_CREATED)

class VerifyOTPView(APIView):
    """Vérifie le code OTP et connecte l'utilisateur en lui donnant son Token"""
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data['email']
        otp_code = serializer.validated_data['otp_code']

        try:
            user = User.objects.get(email=email)
            if user.otp_code == otp_code:
                # C'est le bon code ! On valide le compte.
                user.is_email_verified = True
                user.otp_code = None # On vide le code pour qu'il ne soit plus réutilisable
                user.save()
                
                # On lui donne ses clés d'accès JWT
                tokens = get_tokens_for_user(user)
                return Response({"message": "Email vérifié !", "tokens": tokens}, status=status.HTTP_200_OK)
            
            return Response({"error": "Code OTP incorrect."}, status=status.HTTP_400_BAD_REQUEST)
        
        except User.DoesNotExist:
            return Response({"error": "Utilisateur introuvable."}, status=status.HTTP_404_NOT_FOUND)