from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from drf_spectacular.utils import extend_schema
from django.utils import timezone

from .models import RewardProfile, Referral, Mission, UserMissionLog
from .serializers import RewardProfileSerializer, ApplyCodeSerializer
from economy.models import UserWallet, CoinTransaction

# ==========================================
# PARRAINAGE & RÉSUMÉ (Ton code existant)
# ==========================================

class RewardSummaryView(APIView):
    """ GET /api/rewards/ : Voir XP, Niveau, Code et Parrainages """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def get(self, request):
        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        referrals_count = Referral.objects.filter(referrer=request.user).count()
        
        serializer = RewardProfileSerializer(profile)
        data = serializer.data
        data['total_referrals'] = referrals_count
        return Response(data, status=status.HTTP_200_OK)

class ApplyReferralCodeView(APIView):
    """ POST /api/rewards/apply-code/ : Gagner des Coins et de l'XP via parrainage """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"], request=ApplyCodeSerializer)
    def post(self, request):
        code = request.data.get('code')
        if not code:
            return Response({"error": "Code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        if Referral.objects.filter(referred_user=request.user).exists():
            return Response({"error": "Vous avez déjà été parrainé."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            referrer_profile = RewardProfile.objects.get(referral_code=code)
            referrer = referrer_profile.user
            
            if referrer == request.user:
                return Response({"error": "Auto-parrainage interdit !"}, status=status.HTTP_400_BAD_REQUEST)

            # 1. Créer le lien
            Referral.objects.create(referrer=referrer, referred_user=request.user)
            
            # 2. Récompense pour le PARRAIN
            reward_coins = 50
            reward_xp = 20
            
            ref_wallet, _ = UserWallet.objects.get_or_create(user=referrer)
            ref_wallet.balance += reward_coins
            ref_wallet.save()
            
            # Utilisation de add_xp (qui gère le passage de niveau)
            referrer_profile.add_xp(reward_xp)

            CoinTransaction.objects.create(
                user=referrer, transaction_type='EARN', amount=reward_coins,
                source='referral', description=f"Parrainage de {request.user.username}"
            )

            # 3. Récompense pour le FILLEUL
            my_wallet, _ = UserWallet.objects.get_or_create(user=request.user)
            my_wallet.balance += reward_coins
            my_wallet.save()

            CoinTransaction.objects.create(
                user=request.user, transaction_type='EARN', amount=reward_coins,
                source='referral', description=f"Code parrainage de {referrer.username} utilisé"
            )

            return Response({
                "message": f"Succès ! Vous avez gagné {reward_coins} Coins.",
                "new_balance": my_wallet.balance
            }, status=status.HTTP_200_OK)

        except RewardProfile.DoesNotExist:
            return Response({"error": "Code invalide."}, status=status.HTTP_404_NOT_FOUND)


# ==========================================
# MISSIONS (Mises à jour)
# ==========================================

class DailyMissionsView(APIView):
    """ GET /api/missions/daily """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def get(self, request):
        today = timezone.now().date()
        missions = Mission.objects.filter(mission_type='DAILY', is_active=True)
        
        data = []
        for m in missions:
            completed = UserMissionLog.objects.filter(user=request.user, mission=m, completed_at__date=today).exists()
            data.append({
                "id": m.id,
                "title": m.title,
                "reward_xp": m.reward_xp,
                "completed": completed
            })
        return Response({"missions": data}, status=status.HTTP_200_OK)

class WeeklyMissionsView(APIView):
    """ GET /api/missions/weekly """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def get(self, request):
        week_ago = timezone.now() - timezone.timedelta(days=7)
        missions = Mission.objects.filter(mission_type='WEEKLY', is_active=True)
        
        data = []
        for m in missions:
            completed = UserMissionLog.objects.filter(user=request.user, mission=m, completed_at__gte=week_ago).exists()
            data.append({
                "id": m.id,
                "title": m.title,
                "reward_xp": m.reward_xp,
                "progress": 1 if completed else 0,
                "completed": completed
            })
        return Response({"missions": data}, status=status.HTTP_200_OK)

class CompleteMissionView(APIView):
    """ POST /api/missions/{mission_id}/complete/ : Valider une mission """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def post(self, request, mission_id):
        try:
            mission = Mission.objects.get(id=mission_id, is_active=True)
        except Mission.DoesNotExist:
            return Response({"error": "Mission non trouvée"}, status=status.HTTP_404_NOT_FOUND)

        # Anti-triche : on vérifie si déjà faite aujourd'hui pour les DAILY
        today = timezone.now().date()
        if mission.mission_type == 'DAILY' and UserMissionLog.objects.filter(user=request.user, mission=mission, completed_at__date=today).exists():
            return Response({"error": "Mission déjà accomplie aujourd'hui"}, status=status.HTTP_400_BAD_REQUEST)

        # Sauvegarde dans l'historique des missions accomplies
        UserMissionLog.objects.create(user=request.user, mission=mission)

        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        wallet, _ = UserWallet.objects.get_or_create(user=request.user)

        # Gain XP (la méthode add_xp calcule automatiquement le niveau)
        profile.add_xp(mission.reward_xp)
        
        # Gain Coins
        wallet.balance += mission.reward_coins
        wallet.save()

        CoinTransaction.objects.create(
            user=request.user, transaction_type='EARN', amount=mission.reward_coins,
            source='mission', description=f"Mission validée: {mission.title}"
        )

        # La réponse exacte que Fadwa attend !
        return Response({
            "success": True, 
            "xp_earned": mission.reward_xp
        }, status=status.HTTP_200_OK)


# ==========================================
# XP & NIVEAUX
# ==========================================

class UserXPView(APIView):
    """ GET /api/user/xp """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def get(self, request):
        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        return Response({
            "total_xp": profile.total_xp,
            "current_level": profile.current_level,
            "xp_next_level": profile.xp_required_for_next_level
        }, status=status.HTTP_200_OK)

class UserLevelView(APIView):
    """ GET /api/user/level """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def get(self, request):
        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        return Response({
            "level": profile.current_level,
            "xp_current": profile.total_xp,
            "xp_required": profile.xp_required_for_next_level
        }, status=status.HTTP_200_OK)

class AddXPView(APIView):
    """ POST /api/user/xp/add """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Rewards"])
    def post(self, request):
        amount = int(request.data.get('xp_amount', 0))
        if amount <= 0:
            return Response({"success": False, "error": "Montant invalide"}, status=status.HTTP_400_BAD_REQUEST)

        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        new_level = profile.add_xp(amount)

        return Response({
            "success": True,
            "new_level": new_level,
            "new_xp": profile.total_xp
        }, status=status.HTTP_200_OK)