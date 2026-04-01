from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import authenticate
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken

#  AJOUT POUR SWAGGER : Permet de documenter les APIView personnalisées
from drf_spectacular.utils import extend_schema

from accounts.serializers.profile import UserProfileSerializer, BadgeSerializer
from accounts.serializers.auth import ChangePasswordSerializer

class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated] 

    def get_object(self):
        return self.request.user
    

class UpdateUserProfileV2View(generics.UpdateAPIView):
    """ 
    PUT/PATCH /api/user/profile/v2/ 
    Mise à jour du profil V2 (incluant l'avatar_url 3D Ready Player Me) 
    """
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class UserAvatarView(APIView):
    """
    GET /api/user/avatar/
    Retourne uniquement l'URL de l'avatar 3D (Ready Player Me) de l'utilisateur connecté.
    """
    permission_classes = [IsAuthenticated]

    #  CORRECTION SWAGGER : On lui dit exactement à quoi ressemble la réponse
    @extend_schema(responses={200: {"type": "object", "properties": {"avatar_url": {"type": "string"}}}})
    def get(self, request):
        user = request.user
        return Response({
            "avatar_url": user.avatar_url
        }, status=status.HTTP_200_OK)


class ChangePasswordView(APIView):
    """ PUT /api/user/change-password : Changer le mot de passe depuis le profil  """
    permission_classes = [IsAuthenticated]
    serializer_class = ChangePasswordSerializer

    def put(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        if serializer.is_valid():
            user = request.user
            
            if not user.has_usable_password():
                return Response(
                    {"detail": "Vous êtes connecté via Google, vous ne pouvez pas changer de mot de passe ici."}, 
                    status=status.HTTP_400_BAD_REQUEST
                )

            if not user.check_password(serializer.validated_data.get("old_password")):
                return Response({"detail": "Ancien mot de passe incorrect."}, status=status.HTTP_400_BAD_REQUEST)
            
            user.set_password(serializer.validated_data.get("new_password"))
            user.save()
            return Response({"detail": "Mot de passe mis à jour avec succès."}, status=status.HTTP_200_OK)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserBadgesView(generics.ListAPIView):
    """Retourne la liste des badges de l'utilisateur connecté"""
    serializer_class = BadgeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        #  CORRECTION SWAGGER : Évite le crash "AnonymousUser" quand le robot scanne
        if getattr(self, "swagger_fake_view", False):
            return BadgeSerializer.Meta.model.objects.none()
        return self.request.user.badges.all()


class DeleteAccountView(APIView):
    """ DELETE /api/user/delete-account/ : Suppression définitive du compte """
    permission_classes = [IsAuthenticated]

    #  CORRECTION SWAGGER : On lui dit qu'il n'y a pas de données renvoyées (204 No Content)
    @extend_schema(responses={204: None})
    def delete(self, request):
        user = request.user
        user.delete() 
        return Response(
            {"detail": "Votre compte a été supprimé définitivement conformément au RGPD."}, 
            status=status.HTTP_204_NO_CONTENT
        )

class LogoutAllDevicesView(APIView):
    """ POST /api/user/logout-all/ : Déconnecter tous les appareils """
    permission_classes = [IsAuthenticated]

    #  CORRECTION SWAGGER : On lui donne le format de la réponse texte
    @extend_schema(responses={200: {"type": "object", "properties": {"detail": {"type": "string"}}}})
    def post(self, request):
        tokens = OutstandingToken.objects.filter(user=request.user)
        for token in tokens:
            BlacklistedToken.objects.get_or_create(token=token)
        
        return Response(
            {"detail": "Vous avez été déconnecté de tous vos appareils avec succès."}, 
            status=status.HTTP_200_OK
        )