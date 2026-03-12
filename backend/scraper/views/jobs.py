from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from drf_spectacular.utils import extend_schema  # <-- Import pour Swagger
from scraper.services.orchestrator import ScrapingOrchestrator
from scraper.serializers import SearchRequestSerializer, BulkSearchRequestSerializer # <-- Tes nouveaux serializers

class LiveSearchAPIView(APIView):
    """
    Endpoint pour rechercher/scraper un produit en temps réel (Aperçu).
    NE SAUVEGARDE PAS en base de données pour éviter de la polluer.
    """
    
    # On dit à Swagger : "Utilise ce formulaire pour cet endpoint"
    @extend_schema(request=SearchRequestSerializer)
    def post(self, request):
        user_input = request.data.get('query') or request.data.get('url')
        platform = request.data.get('platform', 'aliexpress')

        if not user_input:
            return Response(
                {"error": "Une recherche (query) ou une URL est obligatoire."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # On lance l'orchestrateur (Scraping + Analyse IA en MAD)
            preview_data = ScrapingOrchestrator.run_live_search(user_input, platform)
            
            return Response({
                "message": "Aperçu généré avec succès.",
                "data": preview_data
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {"error": f"L'extraction en temps réel a échoué: {str(e)}"}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class BulkLiveSearchAPIView(APIView):
    """
    Génère des aperçus pour plusieurs requêtes.
    (Idéal pour ton administration si tu veux vérifier plusieurs produits d'un coup).
    """
    
    # On dit à Swagger : "Utilise cet autre formulaire ici"
    @extend_schema(request=BulkSearchRequestSerializer)
    def post(self, request):
        items = request.data.get('items') or request.data.get('urls', [])
        platform = request.data.get('platform', 'aliexpress')
        
        if not items or not isinstance(items, list):
            return Response(
                {"error": "Une liste 'items' (titres ou URLs) est requise."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        results = []
        for item in items:
            try:
                data = ScrapingOrchestrator.run_live_search(item, platform)
                results.append({"input": item, "status": "success", "data": data})
            except Exception as e:
                results.append({"input": item, "status": "failed", "error": str(e)})

        return Response({
            "message": f"{len(items)} éléments analysés en direct.",
            "details": results
        }, status=status.HTTP_200_OK)