from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db import transaction
from django.contrib.auth import get_user_model
from drf_spectacular.utils import extend_schema
import csv
from django.http import HttpResponse

# Imports propres de ton application Economy
from .models import UserWallet, CoinTransaction, ShopItem, UserInventory
from .serializers import (
    UserWalletSerializer, 
    CoinTransactionSerializer, 
    PaymentCheckoutSerializer, 
    ShopItemSerializer
)

User = get_user_model()

INVALID_AMOUNT_ERROR = "Montant invalide"

# ==========================================
# SOLDE ET HISTORIQUE
# ==========================================

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


# ==========================================
# GAIN, DÉPENSE ET TRANSFERT MANUEL
# ==========================================

class EarnCoinsView(APIView):
    """ POST /api/user/coins/earn : Créditer des coins """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"])
    def post(self, request):
        amount = request.data.get('amount')
        source = request.data.get('source', 'unknown')
        
        if not amount or int(amount) <= 0:
            return Response({"error": INVALID_AMOUNT_ERROR}, status=status.HTTP_400_BAD_REQUEST)

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
            return Response({"error": INVALID_AMOUNT_ERROR}, status=status.HTTP_400_BAD_REQUEST)

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

class TransferCoinsView(APIView):
    """ POST /api/user/coins/transfer : Transférer des coins à un autre utilisateur """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"])
    def post(self, request):
        amount = request.data.get('amount')
        receiver_username = request.data.get('receiver_username')

        if not amount or int(amount) <= 0:
            return Response({"error": INVALID_AMOUNT_ERROR}, status=status.HTTP_400_BAD_REQUEST)
        
        amount = int(amount)

        if request.user.username == receiver_username:
            return Response({"error": "Impossible de transférer à vous-même."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            receiver = User.objects.get(username=receiver_username)
        except User.DoesNotExist:
            return Response({"error": "Utilisateur introuvable."}, status=status.HTTP_404_NOT_FOUND)

        sender_wallet, _ = UserWallet.objects.get_or_create(user=request.user)
        receiver_wallet, _ = UserWallet.objects.get_or_create(user=receiver)

        if sender_wallet.balance < amount:
            return Response({"error": "Solde insuffisant."}, status=status.HTTP_400_BAD_REQUEST)

        # Protection de la base de données
        with transaction.atomic():
            sender_wallet.balance -= amount
            sender_wallet.save()
            CoinTransaction.objects.create(
                user=request.user, transaction_type='SPEND', amount=amount,
                source='transfer_out', description=f"Transfert vers {receiver.username}"
            )

            receiver_wallet.balance += amount
            receiver_wallet.save()
            CoinTransaction.objects.create(
                user=receiver, transaction_type='EARN', amount=amount,
                source='transfer_in', description=f"Reçu de {request.user.username}"
            )

        return Response({"success": True, "message": "Transfert réussi !", "new_balance": sender_wallet.balance}, status=status.HTTP_200_OK)


# ==========================================
# PAIEMENT EXTERNE (CHECKOUT)
# ==========================================

class CheckoutPaymentView(APIView):
    """ POST /api/economy/payments/checkout/ : Traiter un paiement """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"], request=PaymentCheckoutSerializer)
    def post(self, request):
        serializer = PaymentCheckoutSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

        method = serializer.validated_data['payment_method']
        amount = serializer.validated_data['amount']
        
        try:
            coins_earned = int(float(amount) * 10)
        except ValueError:
            return Response({"success": False, "error": INVALID_AMOUNT_ERROR}, status=status.HTTP_400_BAD_REQUEST)
        
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


# ==========================================
# BOUTIQUE ET INVENTAIRE
# ==========================================

class ShopItemListView(generics.ListAPIView):
    """ GET /api/shop/items : Lister les articles de la boutique """
    queryset = ShopItem.objects.filter(is_active=True)
    serializer_class = ShopItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @extend_schema(tags=["Shop"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

class BuyItemView(APIView):
    """ POST /api/shop/items/{id}/buy/ : Acheter un article """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Shop"])
    def post(self, request, pk):
        item = get_object_or_404(ShopItem, pk=pk, is_active=True)
        
        if UserInventory.objects.filter(user=request.user, item=item).exists():
            return Response({"error": "Vous possédez déjà cet article."}, status=status.HTTP_400_BAD_REQUEST)

        wallet, _ = UserWallet.objects.get_or_create(user=request.user)

        if wallet.balance < item.price:
            return Response({"error": "Fonds insuffisants. Jouez plus pour gagner des Coins !"}, status=status.HTTP_400_BAD_REQUEST)

        # Protection atomique pour éviter les bugs d'inventaire
        with transaction.atomic():
            wallet.balance -= item.price
            wallet.save()

            UserInventory.objects.create(user=request.user, item=item)

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

class ShopItemDetailView(generics.RetrieveUpdateDestroyAPIView):
    """ 
    GET /api/shop/items/{id}/ : Voir un article
    PUT /api/shop/items/{id}/ : Modifier un article (ADMIN SEULEMENT)
    DELETE /api/shop/items/{id}/ : Supprimer un article (ADMIN SEULEMENT)
    """
    queryset = ShopItem.objects.all()
    serializer_class = ShopItemSerializer
    
    # Seuls les superusers (is_staff=True) peuvent utiliser cette vue
    permission_classes = [permissions.IsAdminUser]

# ==========================================
# EXPORT ET JOURNAL DÉTAILLÉ (Fadwa)
# ==========================================

class TransactionLogExportView(APIView):
    """ GET /api/user/coins/transaction-log : Export/Journal détaillé (JSON ou CSV) """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Economy"])
    def get(self, request):
        # On récupère toutes les transactions de l'utilisateur
        transactions = CoinTransaction.objects.filter(user=request.user).order_by('-timestamp')
        
        # Option pour export CSV (ex: ?format=csv)
        format_type = request.query_params.get('format', 'json')

        if format_type == 'csv':
            response = HttpResponse(content_type='text/csv')
            response['Content-Disposition'] = 'attachment; filename="transactions_finder.csv"'
            writer = csv.writer(response)
            writer.writerow(['Date', 'Type', 'Montant', 'Source', 'Description'])
            for t in transactions:
                writer.writerow([
                    t.timestamp.strftime("%Y-%m-%d %H:%M"),
                    t.get_transaction_type_display(),
                    t.amount,
                    t.source,
                    t.description or ""
                ])
            return response

        # Format JSON par défaut (pour l'affichage direct dans l'app)
        data = [{
            "id": t.id,
            "date": t.timestamp,
            "type_code": t.transaction_type,
            "type_label": t.get_transaction_type_display(),
            "amount": t.amount,
            "source": t.source,
            "description": t.description
        } for t in transactions]

        return Response({"count": len(data), "logs": data}, status=status.HTTP_200_OK)