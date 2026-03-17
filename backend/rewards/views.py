from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from drf_spectacular.utils import extend_schema
from django.utils import timezone
from datetime import timedelta
from django.db.models import Count
from django.db.models.functions import TruncDate

from .models import RewardProfile, Referral, Mission, UserMissionLog
from .serializers import RewardProfileSerializer, ApplyCodeSerializer
from economy.models import UserWallet, CoinTransaction

# ==========================================
# 1. PARRAINAGE & RÉSUMÉ (Bloc Growth - P2)
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

class ReferralInviteView(APIView):
    """ POST /api/user/referral-invite : Générer lien et code d'invitation """
    permission_classes = [permissions.IsAuthenticated]
    
    @extend_schema(tags=["Growth"])
    def post(self, request):
        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        # On simule la construction d'un lien basé sur ton domaine front-end
        invite_link = f"https://finder.com/ref/{profile.referral_code}"
        
        return Response({
            "invite_code": profile.referral_code, 
            "invite_link": invite_link
        }, status=status.HTTP_200_OK)

class UserReferralsView(APIView):
    """ GET /api/user/referrals : Liste des filleuls """
    permission_classes = [permissions.IsAuthenticated]
    
    @extend_schema(tags=["Growth"])
    def get(self, request):
        referrals = Referral.objects.filter(referrer=request.user)
        data = [
            {"id": ref.id, "email": ref.referred_user.email, "date": ref.created_at.strftime('%Y-%m-%d')} 
            for ref in referrals
        ]
        return Response({"referrals": data}, status=status.HTTP_200_OK)

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
# 2. MISSIONS (Daily & Weekly - P1)
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

        today = timezone.now().date()
        if mission.mission_type == 'DAILY' and UserMissionLog.objects.filter(user=request.user, mission=mission, completed_at__date=today).exists():
            return Response({"error": "Mission déjà accomplie aujourd'hui"}, status=status.HTTP_400_BAD_REQUEST)

        UserMissionLog.objects.create(user=request.user, mission=mission)

        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        wallet, _ = UserWallet.objects.get_or_create(user=request.user)

        profile.add_xp(mission.reward_xp)
        wallet.balance += mission.reward_coins
        wallet.save()

        CoinTransaction.objects.create(
            user=request.user, transaction_type='EARN', amount=mission.reward_coins,
            source='mission', description=f"Mission validée: {mission.title}"
        )

        return Response({"success": True, "xp_earned": mission.reward_xp}, status=status.HTTP_200_OK)


# ==========================================
# 3. XP & NIVEAUX
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

        return Response({"success": True, "new_level": new_level, "new_xp": profile.total_xp}, status=status.HTTP_200_OK)


# ==========================================
# 4. DASHBOARD & STREAK (Bloc Gamification - P2)
# ==========================================

class UserStreakView(APIView):
    """ GET /api/user/streak """
    permission_classes = [permissions.IsAuthenticated]
    
    @extend_schema(tags=["Gamification"])
    def get(self, request):
        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        return Response({
            "current_streak": profile.current_streak,
            "last_activity": profile.last_activity_date
        }, status=status.HTTP_200_OK)

class UpdateStreakView(APIView):
    """ POST /api/user/streak/update """
    permission_classes = [permissions.IsAuthenticated]
    
    @extend_schema(tags=["Gamification"])
    def post(self, request):
        profile, _ = RewardProfile.objects.get_or_create(user=request.user)
        today = timezone.now().date()
        yesterday = today - timedelta(days=1)

        if profile.last_activity_date == today:
            message = "Déjà mis à jour aujourd'hui."
        elif profile.last_activity_date == yesterday:
            profile.current_streak += 1
            message = "Série augmentée !"
        else:
            profile.current_streak = 1
            message = "Série réinitialisée."

        profile.last_activity_date = today
        profile.save()

        return Response({"success": True, "message": message, "current_streak": profile.current_streak}, status=status.HTTP_200_OK)

class DashboardChartDataView(APIView):
    """ GET /api/user/dashboard/chart-data """
    permission_classes = [permissions.IsAuthenticated]
    
    @extend_schema(tags=["Dashboard"])
    def get(self, request):
        seven_days_ago = timezone.now() - timedelta(days=7)
        activity_data = UserMissionLog.objects.filter(
            user=request.user, completed_at__gte=seven_days_ago
        ).annotate(date=TruncDate('completed_at')).values('date').annotate(count=Count('id')).order_by('date')

        chart_data = [{"date": item['date'].strftime('%Y-%m-%d'), "value": item['count']} for item in activity_data]
        return Response({"chart_data": chart_data}, status=status.HTTP_200_OK)

# ==========================================
# 5. AJOUTS POUR LE BLOC GROWTH & VIRALITÉ 
# ==========================================

class ReferralLeaderboardView(APIView):
    """ GET /api/user/referral-leaderboard : Classement des meilleurs parrains """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Growth"])
    def get(self, request):
        # Compte le nombre de filleuls pour chaque parrain et prend le top 10
        leaderboard = Referral.objects.values('referrer__username').annotate(
            total_referrals=Count('id')
        ).order_by('-total_referrals')[:10]
        
        data = [
            {
                "username": item['referrer__username'], 
                "referrals": item['total_referrals']
            } for item in leaderboard
        ]
        return Response({"leaderboard": data}, status=status.HTTP_200_OK)

class ReferralRewardsView(APIView):
    """ GET /api/user/referral/rewards : Liste des gains potentiels """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Growth"])
    def get(self, request):
        # Données statiques pour le front-end (à lier à un modèle plus tard si besoin)
        rewards = [
            {"id": 1, "required_referrals": 5, "reward_coins": 500, "status": "locked"},
            {"id": 2, "required_referrals": 10, "reward_coins": 1500, "status": "locked"},
            {"id": 3, "required_referrals": 25, "reward_coins": 5000, "status": "locked"},
        ]
        return Response({"rewards": rewards}, status=status.HTTP_200_OK)

class ClaimReferralRewardView(APIView):
    """ POST /api/user/referral/claim-reward : Réclamer les coins après validation """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Growth"])
    def post(self, request):
        reward_id = request.data.get('reward_id')
        
        if not reward_id:
            return Response({"error": "L'ID de la récompense est requis."}, status=status.HTTP_400_BAD_REQUEST)
            
        # Logique simplifiée en attendant la validation stricte des paliers
        return Response({
            "success": True, 
            "message": f"Récompense {reward_id} réclamée avec succès ! Les coins seront ajoutés après vérification."
        }, status=status.HTTP_200_OK)