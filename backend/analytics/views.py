from rest_framework.views import APIView
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

# Import de tes modèles et serializers
from .models import UserActivity
from .serializers import ROICalculatorSerializer, UserActivitySerializer

# ==========================================
# 1. CALCULATEUR ROI (Ton code original intact)
# ==========================================
class ROICalculatorAPIView(APIView):
    """
    Simulateur de profitabilité pour le marché Marocain (COD).
    """
    permission_classes = [permissions.AllowAny] # Ou IsAuthenticated si tu veux le bloquer

    @extend_schema(request=ROICalculatorSerializer, tags=["Business Analytics"])
    def post(self, request):
        serializer = ROICalculatorSerializer(data=request.data)
        if serializer.is_valid():
            d = serializer.validated_data
            
            # Simulation sur une base de 100 commandes générées
            orders = 100
            confirmed = orders * d['confirmation_rate']
            delivered = confirmed * d['delivery_rate']
            returned = confirmed - delivered
            
            # Chiffre d'affaire
            revenue = delivered * d['selling_price']
            
            # Coûts totaux
            purchase_cost = confirmed * d['product_cost']  # On paie le stock confirmé
            ads_total = orders * d['ads_cost_per_order']
            shipping_total = delivered * d['shipping_cost']
            return_fees = returned * 15.0 # Frais moyens de retour au Maroc
            
            total_costs = purchase_cost + ads_total + shipping_total + return_fees
            net_profit = revenue - total_costs
            
            return Response({
                "summary": {
                    "net_profit": round(net_profit, 2),
                    "roi_percentage": round((net_profit / total_costs * 100), 2) if total_costs > 0 else 0,
                    "profit_per_order": round(net_profit / delivered, 2) if delivered > 0 else 0
                },
                "metrics": {
                    "confirmed_orders": confirmed,
                    "delivered_orders": delivered,
                    "returned_orders": returned
                }
            }, status=status.HTTP_200_OK)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ==========================================
# 2. TABLEAU DE BORD (Nouvelles vues)
# ==========================================
class DashboardStatsView(APIView):
    """ GET /api/dashboard/stats : Statistiques globales de l'utilisateur """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Dashboard"])
    def get(self, request):
        user = request.user
        
        # Calcul des statistiques
        total_activities = UserActivity.objects.filter(user=user).count()
        recent_searches = UserActivity.objects.filter(user=user, action__icontains="Recherche").count()
        
        # Vérification si l'utilisateur est premium
        is_premium = False
        plan_name = "Gratuit"
        
        # Utilisation de getattr pour éviter les erreurs si l'utilisateur n'a pas de profil d'abonnement
        if hasattr(user, 'subscription') and getattr(user.subscription, 'is_active', False):
            is_premium = True
            plan_name = user.subscription.plan.name if user.subscription.plan else "Premium"

        stats = {
            "total_activities": total_activities,
            "recent_searches": recent_searches,
            "is_premium": is_premium,
            "plan_name": plan_name,
            "points_earned": 0, # Prêt pour le module récompenses
        }
        return Response(stats, status=status.HTTP_200_OK)

class RecentActivityView(generics.ListAPIView):
    """ GET /api/dashboard/recent-activity : Historique des dernières actions """
    serializer_class = UserActivitySerializer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Dashboard"])
    def get_queryset(self):
        # On retourne uniquement les 10 dernières actions de l'utilisateur connecté
        return UserActivity.objects.filter(user=self.request.user)[:10]