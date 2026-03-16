from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from drf_spectacular.utils import extend_schema

# Tes imports de modèles
from economy.models import Wallet
from products.models import Product
from rewards.models import UserMission
from .serializers import DashboardStatsSerializer, DashboardChartsListSerializer

class DashboardStatsView(APIView):
    """ Statistiques et Série de jours (Streak) """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: DashboardStatsSerializer}, tags=["Dashboard"])
    def get(self, request):
        user = request.user
        wallet, _ = Wallet.objects.get_or_create(user=user)
        
        total_products_found = Product.objects.filter(added_by=user).count()
        missions_completed = UserMission.objects.filter(user=user, status='COMPLETED').count()
        streak_count = getattr(user, 'current_streak', 5)

        data = {
            "stats": {
                "balance_coins": wallet.balance,
                "products_found": total_products_found,
                "missions_done": missions_completed,
                "xp": getattr(user, 'xp', 0),
            },
            "streak": {
                "count": streak_count,
                "message": f"Vous êtes en feu ! {streak_count} jours d'affilée."
            }
        }
        
        serializer = DashboardStatsSerializer(data)
        return Response(serializer.data)

class DashboardChartsView(APIView):
    """ Ligne 7 : Données pour le graphique des gains (Coins) """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: DashboardChartsListSerializer}, tags=["Dashboard"])
    def get(self, request):
        data_points = [
            {"day": "Lun", "amount": 120},
            {"day": "Mar", "amount": 450},
            {"day": "Mer", "amount": 300},
            {"day": "Jeu", "amount": 900},
            {"day": "Ven", "amount": 550},
            {"day": "Sam", "amount": 800},
            {"day": "Dim", "amount": 1100},
        ]
        
        response_data = {
            "chart_data": data_points,
            "period": "Last 7 Days",
            "total_period": sum(d['amount'] for d in data_points)
        }
        
        serializer = DashboardChartsListSerializer(response_data)
        return Response(serializer.data)