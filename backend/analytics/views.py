from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .serializers import ROICalculatorSerializer

class ROICalculatorAPIView(APIView):
    """
    Simulateur de profitabilité pour le marché Marocain (COD).
    """
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
            })
        return Response(serializer.errors, status=400)