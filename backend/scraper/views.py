from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .services import ScraperService
from products.serializers import ProductSerializer
from drf_spectacular.utils import extend_schema, OpenApiExample

class ScrapeProductView(APIView):
    """Endpoint pour importer un produit via une URL (AliExpress, DHgate, CJ) ou une recherche par titre."""
    
    def post(self, request):
        # On accepte 'query' (nouveau format pour la recherche) ou 'url' (ancien format)
        user_input = request.data.get('query') or request.data.get('url')
        
        if not user_input:
            return Response(
                {"error": "Une URL ou un nom de produit est obligatoire."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # On utilise la nouvelle méthode import_product !
        product, error = ScraperService.import_product(user_input)
        
        if error:
            return Response(
                {"error": f"L'importation a échoué: {error}"}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
        serializer = ProductSerializer(product)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    


class BulkScrapeView(APIView):
    """Importation massive de produits (AliExpress, DHgate, CJ Dropshipping via URLs ou titres)."""

    @extend_schema(
        request={"application/json": {"example": {"items": ["https://dhgate.com/...", "montre sport"]}}},
        responses={200: {"example": {"success_count": 1, "errors": []}}}
    )
    def post(self, request):
        # On accepte 'items' (générique) ou 'urls' (pour garder la compatibilité avec l'ancien code)
        items = request.data.get('items') or request.data.get('urls', [])
        
        if not items or not isinstance(items, list):
            return Response(
                {"error": "Une liste d'URLs ou de titres de produits est requise."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        results = []
        success_count = 0
        
        for item in items:
            # 👇 CORRECTION : On utilise la nouvelle méthode import_product !
            product, error = ScraperService.import_product(item)
            if product:
                success_count += 1
                results.append({"input": item, "status": "success", "id": product.id})
            else:
                results.append({"input": item, "status": "failed", "error": error})

        return Response({
            "message": f"{success_count} produits importés avec succès.",
            "details": results
        }, status=status.HTTP_200_OK)