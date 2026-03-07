from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .services import ScraperService
from products.serializers import ProductSerializer
from drf_spectacular.utils import extend_schema, OpenApiExample

class ScrapeProductView(APIView):
    """Endpoint pour importer un produit via une URL."""
    
    def post(self, request):
        url = request.data.get('url')
        if not url:
            return Response({"error": "L'URL est obligatoire"}, status=status.HTTP_400_BAD_REQUEST)

        product, error = ScraperService.import_aliexpress_product(url)
        
        if error:
            return Response({"error": f"Le scraping a échoué: {error}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
        serializer = ProductSerializer(product)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    


class BulkScrapeView(APIView):
    """Importation massive de produits AliExpress."""

    @extend_schema(
        request={"application/json": {"example": {"urls": ["url1", "url2"]}}},
        responses={200: {"example": {"success_count": 1, "errors": []}}}
    )
    def post(self, request):
        urls = request.data.get('urls', [])
        if not urls or not isinstance(urls, list):
            return Response({"error": "Une liste d'URLs est requise."}, status=status.HTTP_400_BAD_REQUEST)

        results = []
        success_count = 0
        
        for url in urls:
            product, error = ScraperService.import_aliexpress_product(url)
            if product:
                success_count += 1
                results.append({"url": url, "status": "success", "id": product.id})
            else:
                results.append({"url": url, "status": "failed", "error": error})

        return Response({
            "message": f"{success_count} produits importés avec succès.",
            "details": results
        }, status=status.HTTP_200_OK)