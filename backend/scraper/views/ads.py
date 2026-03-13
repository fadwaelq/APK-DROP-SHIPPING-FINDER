from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiParameter
from products.models import AdCampaign
from products.serializers import AdCampaignSerializer

class AdsMonitoringAPIView(APIView):
    """
    Récupère les publicités concurrentes pour un mot-clé ou un produit.
    """
    @extend_schema(
        tags=["Spy"],
        parameters=[
            OpenApiParameter(name="query", description="Mot-clé (ex: montre)", type=str),
            OpenApiParameter(name="platform", description="tiktok ou facebook", type=str),
        ]
    )
    def get(self, request):
        query = request.query_params.get('query')
        platform = request.query_params.get('platform', 'tiktok')
        
        # Pour le MVP : On cherche d'abord en base de données
        ads = AdCampaign.objects.filter(title__icontains=query) if query else AdCampaign.objects.all()
        
        if not ads.exists():
            # Ici, tu pourrais appeler une tâche Celery pour scraper TikTok en temps réel
            return Response({
                "message": "Aucune publicité en base. Lancement d'une recherche en arrière-plan...",
                "status": "searching"
            })
            
        serializer = AdCampaignSerializer(ads, many=True)
        return Response(serializer.data)