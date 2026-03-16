from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import authenticate

from accounts.serializers.profile import UserProfileSerializer, BadgeSerializer
from accounts.serializers.auth import ChangePasswordSerializer

class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated] 

    def get_object(self):
        # On renvoie l'utilisateur lié au token
        return self.request.user
    

class UpdateUserProfileV2View(generics.UpdateAPIView):
    """ 
    PUT/PATCH /api/user/profile/v2/ 
    Mise à jour du profil V2 (incluant l'avatar_url 3D Ready Player Me) 
    """
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        # On s'assure que l'utilisateur ne peut modifier que son propre profil
        return self.request.user


class UserAvatarView(APIView):
    """
    GET /api/user/avatar/
    Retourne uniquement l'URL de l'avatar 3D (Ready Player Me) de l'utilisateur connecté.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # L'utilisateur est automatiquement identifié grâce à son token JWT
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
            
            # Si l'utilisateur s'est inscrit via Google, il n'a pas d'ancien mot de passe
            if not user.has_usable_password():
                return Response(
                    {"detail": "Vous êtes connecté via Google, vous ne pouvez pas changer de mot de passe ici."}, 
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Vérifier l'ancien mot de passe
            if not user.check_password(serializer.validated_data.get("old_password")):
                return Response({"detail": "Ancien mot de passe incorrect."}, status=status.HTTP_400_BAD_REQUEST)
            
            # Définir le nouveau mot de passe
            user.set_password(serializer.validated_data.get("new_password"))
            user.save()
            
            return Response({"detail": "Mot de passe mis à jour avec succès."}, status=status.HTTP_200_OK)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserBadgesView(generics.ListAPIView):
    """Retourne la liste des badges de l'utilisateur connecté"""
    serializer_class = BadgeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # On retourne uniquement les badges liés à l'utilisateur qui fait la requête
        return self.request.user.badges.all()