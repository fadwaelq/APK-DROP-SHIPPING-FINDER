from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiTypes

# Imports Services & Serializers
from scraper.services.orchestrator import ScrapingOrchestrator
from scraper.serializers import SearchRequestSerializer, BulkSearchRequestSerializer

# Imports Celery
from celery.result import AsyncResult
from scraper.tasks import scrape_product_async, scrape_bulk_async

# =====================================================================
# 1. VUES SYNCHRONES (Aperçu direct / Bloquant)
# =====================================================================

class LiveSearchAPIView(APIView):
    """Recherche unitaire en temps réel."""
    @extend_schema(request=SearchRequestSerializer, tags=["Scraper Synchrone"])
    def post(self, request):
        user_input = request.data.get('query') or request.data.get('url')
        platform = request.data.get('platform', 'aliexpress')
        if not user_input:
            return Response({"error": "Query obligatoire."}, status=400)
        try:
            preview_data = ScrapingOrchestrator.run_live_search(user_input, platform)
            return Response({"data": preview_data}, status=200)
        except Exception as e:
            return Response({"error": str(e)}, status=500)

class BulkLiveSearchAPIView(APIView):
    """Recherche par lot en temps réel."""
    @extend_schema(request=BulkSearchRequestSerializer, tags=["Scraper Synchrone"])
    def post(self, request):
        items = request.data.get('items') or request.data.get('urls', [])
        platform = request.data.get('platform', 'aliexpress')
        if not isinstance(items, list):
            return Response({"error": "Liste requise."}, status=400)
        
        results = []
        for item in items:
            try:
                data = ScrapingOrchestrator.run_live_search(item, platform)
                results.append({"input": item, "status": "success", "data": data})
            except Exception as e:
                results.append({"input": item, "status": "failed", "error": str(e)})
        return Response({"details": results}, status=200)

# =====================================================================
# 2. VUES ASYNCHRONES (Celery / Non-bloquant / Flutter)
# =====================================================================

class ScrapeAsyncAPIView(APIView):
    """Lance un scraping unitaire en arrière-plan."""
    @extend_schema(request=SearchRequestSerializer, tags=["Scraper Asynchrone"])
    def post(self, request):
        query = request.data.get('query', '')
        if not query:
            return Response({"error": "Query obligatoire."}, status=400)
        task = scrape_product_async.delay(query)
        return Response({"task_id": task.id, "message": "Tâche lancée."}, status=202)

class BulkScrapeAsyncAPIView(APIView):
    """Lance un scraping par lot en arrière-plan."""
    @extend_schema(request=BulkSearchRequestSerializer, tags=["Scraper Asynchrone"])
    def post(self, request):
        items = request.data.get('items') or request.data.get('urls', [])
        platform = request.data.get('platform', 'aliexpress')
        if not isinstance(items, list):
            return Response({"error": "Liste requise."}, status=400)
        
        task = scrape_bulk_async.delay(items, platform)
        return Response({"task_id": task.id, "message": f"Lot de {len(items)} lancé."}, status=202)

class ScrapeStatusAPIView(APIView):
    """Vérifie l'état d'une tâche (Single ou Bulk)."""
    @extend_schema(
        tags=["Scraper Asynchrone"],
        parameters=[OpenApiParameter(name="task_id", type=OpenApiTypes.STR, location=OpenApiParameter.PATH)]
    )
    def get(self, request, task_id):
        task_result = AsyncResult(task_id)
        response_data = {"task_id": task_id, "status": task_result.status}
        if task_result.status == 'SUCCESS':
            response_data['result'] = task_result.result
        elif task_result.status == 'FAILURE':
            response_data['error'] = str(task_result.info)
        return Response(response_data, status=200)