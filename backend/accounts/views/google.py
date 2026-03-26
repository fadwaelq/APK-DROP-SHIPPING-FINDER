from rest_framework import views, status, permissions, serializers 
from django.contrib.auth import get_user_model
from google.oauth2 import id_token
from google.auth.transport import requests
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken

# AJOUT POUR SWAGGER
from drf_spectacular.utils import extend_schema

User = get_user_model()

class GoogleTokenSerializer(serializers.Serializer):
    id_token = serializers.CharField(help_text="Le token JWT reçu de l'application Google (frontend)")

class GoogleLoginView(views.APIView):
    """ POST /api/accounts/google-login/ : Connexion ou Inscription via Google """
    permission_classes = [permissions.AllowAny]
    serializer_class = GoogleTokenSerializer 

    @extend_schema(
        responses={
            200: {
                "type": "object", 
                "properties": {
                    "refresh": {"type": "string"}, 
                    "access": {"type": "string"},
                    "is_new_user": {"type": "boolean"},
                    "detail": {"type": "string"}
                }
            },
            401: {"type": "object", "properties": {"detail": {"type": "string"}}}
        }
    )
    def post(self, request):
        serializer = GoogleTokenSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        token = serializer.validated_data.get('id_token')

        try:
            idinfo = id_token.verify_oauth2_token(token, requests.Request())
            email = idinfo.get('email')
            first_name = idinfo.get('given_name', '')
            last_name = idinfo.get('family_name', '')

            user, created = User.objects.get_or_create(email=email)

            if created:
                user.username = email.split('@')[0]
                user.first_name = first_name
                user.last_name = last_name
                user.is_email_verified = True
                user.set_unusable_password()
                user.save()

            refresh = RefreshToken.for_user(user)

            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'is_new_user': created,
                'detail': "Connexion Google réussie."
            }, status=status.HTTP_200_OK)

        except ValueError:
            return Response({"detail": "Token Google invalide ou expiré."}, status=status.HTTP_401_UNAUTHORIZED)
        

class ActiveSessionsView(APIView):
    """ GET /api/user/active-sessions/ : Liste le nombre de connexions actives """
    permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={
            200: {
                "type": "object", 
                "properties": {
                    "count": {"type": "integer"}, 
                    "message": {"type": "string"}
                }
            }
        }
    )
    def get(self, request):
        sessions_count = OutstandingToken.objects.filter(user=request.user).count()
        return Response({
            "count": sessions_count,
            "message": f"Il y a actuellement {sessions_count} appareil(s) connecté(s) à votre compte."
        }, status=status.HTTP_200_OK)