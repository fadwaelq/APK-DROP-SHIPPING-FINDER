from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from community import models
from .models import User, User, UserWallet, CoinTransaction,ShopItem

# PaymentCheckoutSerializer
from .serializers import UserWalletSerializer, CoinTransactionSerializer, PaymentCheckoutSerializer, ShopItemSerializer

class CoinBalanceView(APIView):
    """ GET /api/user/coins-balance : Récupérer le solde global """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"], responses=UserWalletSerializer)
    def get(self, request):
        wallet, _ = UserWallet.objects.get_or_create(user=request.user)
        serializer = UserWalletSerializer(wallet)
        return Response(serializer.data, status=status.HTTP_200_OK)

class CoinHistoryView(generics.ListAPIView):
    """ GET /api/user/coins-history : Historique des transactions """
    serializer_class = CoinTransactionSerializer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"])
    def get_queryset(self):
        return CoinTransaction.objects.filter(user=self.request.user).order_by('-timestamp')

class EarnCoinsView(APIView):
    """ POST /api/user/coins/earn : Créditer des coins """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"])
    def post(self, request):
        amount = request.data.get('amount')
        source = request.data.get('source', 'unknown')
        
        if not amount or int(amount) <= 0:
            return Response({"error": "Montant invalide"}, status=status.HTTP_400_BAD_REQUEST)

        wallet, _ = UserWallet.objects.get_or_create(user=request.user)
        wallet.balance += int(amount)
        wallet.save()

        CoinTransaction.objects.create(
            user=request.user, transaction_type='EARN', amount=int(amount), source=source
        )

        return Response({
            "success": True, 
            "new_balance": wallet.balance,
            "timestamp": wallet.last_update
        }, status=status.HTTP_200_OK)

class SpendCoinsView(APIView):
    """ POST /api/user/coins/spend : Débiter des coins """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"])
    def post(self, request):
        amount = request.data.get('amount')
        item_id = request.data.get('item_id', 'unknown')
        
        if not amount or int(amount) <= 0:
            return Response({"error": "Montant invalide"}, status=status.HTTP_400_BAD_REQUEST)

        wallet, _ = UserWallet.objects.get_or_create(user=request.user)
        
        if wallet.balance < int(amount):
            return Response({"success": False, "error": "Solde insuffisant"}, status=status.HTTP_400_BAD_REQUEST)

        wallet.balance -= int(amount)
        wallet.save()

        CoinTransaction.objects.create(
            user=request.user, transaction_type='SPEND', amount=int(amount), source='shop', description=f"Achat item: {item_id}"
        )

        return Response({
            "success": True, 
            "new_balance": wallet.balance,
            "order_id": f"ORD-{request.user.id}-{item_id}"
        }, status=status.HTTP_200_OK)


# ==========================================
# NOUVELLE VUE : CHECKOUT PAIEMENT
# ==========================================
class CheckoutPaymentView(APIView):
    """ POST /api/economy/payments/checkout/ : Traiter un paiement (CB, PayPal, Google Play) """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"], request=PaymentCheckoutSerializer)
    def post(self, request):
        serializer = PaymentCheckoutSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

        method = serializer.validated_data['payment_method']
        amount = serializer.validated_data['amount']
        
        # Logique Mock pour la deadline : 1 Devise = 10 Coins
        try:
            coins_earned = int(float(amount) * 10)
        except ValueError:
            return Response({"success": False, "error": "Montant invalide"}, status=status.HTTP_400_BAD_REQUEST)
        
        wallet, _ = UserWallet.objects.get_or_create(user=request.user)
        wallet.balance += coins_earned
        wallet.save()

        CoinTransaction.objects.create(
            user=request.user, 
            transaction_type='EARN', 
            amount=coins_earned,
            source=f'purchase_{method.lower()}', 
            description=f"Achat de {coins_earned} coins via {method}"
        )

        return Response({
            "success": True,
            "message": f"Paiement {method} validé avec succès !",
            "coins_added": coins_earned,
            "new_balance": wallet.balance
        }, status=status.HTTP_200_OK)



class ShopItemListView(generics.ListAPIView):
    """ GET /api/shop/items : Lister les articles de la boutique """
    queryset = ShopItem.objects.filter(is_active=True)
    serializer_class = ShopItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @extend_schema(tags=["Shop"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    

class ShopItemDetailView(generics.RetrieveUpdateDestroyAPIView):
    """ 
    GET /api/shop/items/{id}/ : Voir un article
    PUT /api/shop/items/{id}/ : Modifier un article (ADMIN SEULEMENT)
    DELETE /api/shop/items/{id}/ : Supprimer un article (ADMIN SEULEMENT)
    """
    queryset = ShopItem.objects.all()
    serializer_class = ShopItemSerializer
    
    # Seuls les superusers (is_staff=True) peuvent utiliser cette vue !
    permission_classes = [permissions.IsAdminUser]

# 👇 AJOUTER À LA FIN DE economy/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import ShopItem, UserInventory, UserWallet, CoinTransaction

class BuyItemView(APIView):
    """ POST /api/shop/items/{id}/buy/ : Acheter un article """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        # On récupère l'article
        item = get_object_or_404(ShopItem, pk=pk, is_active=True)
        
        # On vérifie si le joueur l'a déjà
        if UserInventory.objects.filter(user=request.user, item=item).exists():
            return Response({"error": "Vous possédez déjà cet article."}, status=status.HTTP_400_BAD_REQUEST)

        # On récupère le portefeuille
        wallet, _ = UserWallet.objects.get_or_create(user=request.user)

        # On vérifie les fonds
        if wallet.balance < item.price:
            return Response({"error": "Fonds insuffisants. Jouez plus pour gagner des Coins !"}, status=status.HTTP_400_BAD_REQUEST)

        # On procède à l'achat !
        wallet.balance -= item.price
        wallet.save()

        # On ajoute à l'inventaire
        UserInventory.objects.create(user=request.user, item=item)

        # On trace la transaction (très important pour les logs d'économie)
        CoinTransaction.objects.create(
            user=request.user,
            transaction_type='SPEND',
            amount=item.price,
            source='shop',
            description=f"Achat de l'article: {item.name}"
        )

        return Response({
            "success": True,
            "message": f"Vous avez acheté {item.name} !",
            "new_balance": wallet.balance
        }, status=status.HTTP_200_OK)