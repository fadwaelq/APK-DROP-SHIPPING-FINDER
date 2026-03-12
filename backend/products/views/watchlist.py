from rest_framework import generics, permissions
from products.models import ProductWatchlist
from products.serializers import ProductWatchlistSerializer

class WatchlistAPIView(generics.ListCreateAPIView):
    """
    Workflow 2: Liste les favoris de l'utilisateur et permet d'en ajouter.
    """
    serializer_class = ProductWatchlistSerializer
    permission_classes = [permissions.IsAuthenticated] # Doit être connecté

    def get_queryset(self):
        # Ne retourne QUE les produits de l'utilisateur connecté
        return ProductWatchlist.objects.filter(user=self.request.user).order_by('-added_at')

    def perform_create(self, serializer):
        # Assigne automatiquement le produit au portfolio de l'utilisateur
        serializer.save(user=self.request.user)

class WatchlistDetailAPIView(generics.DestroyAPIView):
    """Permet de retirer un produit du portfolio."""
    serializer_class = ProductWatchlistSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ProductWatchlist.objects.filter(user=self.request.user)