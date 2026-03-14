from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from drf_spectacular.utils import extend_schema
from .models import RewardProfile, Referral
from .serializers import RewardProfileSerializer, ApplyCodeSerializer

class RewardSummaryView(APIView):
    """ GET /api/rewards/ : Voir ses points, son code et le nombre d'amis invités """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def get(self, request):
        # On récupère ou on crée automatiquement le profil de récompense s'il n'existe pas encore
        profile, created = RewardProfile.objects.get_or_create(user=request.user)
        serializer = RewardProfileSerializer(profile)
        
        # On compte combien d'amis cet utilisateur a parrainé
        referrals_count = Referral.objects.filter(referrer=request.user).count()
        
        data = serializer.data
        data['total_referrals'] = referrals_count
        return Response(data, status=status.HTTP_200_OK)

class ApplyReferralCodeView(APIView):
    """ POST /api/rewards/apply-code/ : Entrer le code d'un ami pour gagner des points """
    permission_classes = [permissions.IsAuthenticated]

    # C'EST ICI LA CORRECTION : Ajout de request=ApplyCodeSerializer
    @extend_schema(tags=["Rewards"], request=ApplyCodeSerializer)
    def post(self, request):
        code = request.data.get('code')
        if not code:
            return Response({"error": "Veuillez fournir un code de parrainage."}, status=status.HTTP_400_BAD_REQUEST)
        
        # 1. Vérifier si l'utilisateur n'a pas déjà utilisé un code dans le passé
        if Referral.objects.filter(referred_user=request.user).exists():
            return Response({"error": "Vous avez déjà été parrainé."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # 2. Chercher à qui appartient ce code
            referrer_profile = RewardProfile.objects.get(referral_code=code)
            referrer = referrer_profile.user
            
            # 3. Empêcher l'utilisateur d'utiliser son propre code
            if referrer == request.user:
                return Response({"error": "Vous ne pouvez pas utiliser votre propre code ! 😉"}, status=status.HTTP_400_BAD_REQUEST)

            # 4. Succès : On crée le lien de parrainage
            Referral.objects.create(referrer=referrer, referred_user=request.user)
            
            # 5. On donne les récompenses (Ex: 50 points chacun)
            referrer_profile.points += 50
            referrer_profile.save()
            
            my_profile, _ = RewardProfile.objects.get_or_create(user=request.user)
            my_profile.points += 50
            my_profile.save()

            return Response({"message": "Code appliqué avec succès ! Vous et votre parrain avez gagné 50 points."}, status=status.HTTP_200_OK)

        except RewardProfile.DoesNotExist:
            return Response({"error": "Ce code de parrainage n'existe pas."}, status=status.HTTP_404_NOT_FOUND)