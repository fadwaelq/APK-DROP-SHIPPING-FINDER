from django.urls import path
from .views import (
    BuyItemView, 
    CheckoutPaymentView, 
    CoinBalanceView, 
    CoinHistoryView, 
    EarnCoinsView, 
    ShopItemDetailView, 
    ShopItemListView, 
    SpendCoinsView,
    TransferCoinsView,
    TransactionLogExportView 
)

urlpatterns = [
    # --- Solde et Historique ---
    path('user/coins-balance/', CoinBalanceView.as_view(), name='coins-balance'),
    path('user/coins-history/', CoinHistoryView.as_view(), name='coins-history'),
    
    # --- Gain, Dépense et Transfert P2P ---
    path('user/coins/earn/', EarnCoinsView.as_view(), name='coins-earn'),
    path('user/coins/spend/', SpendCoinsView.as_view(), name='coins-spend'),
    path('user/coins/transfer/', TransferCoinsView.as_view(), name='coins-transfer'),
    
    # --- Journal Détaillé / Export (Fadwa) ---
    path('user/coins/transaction-log/', TransactionLogExportView.as_view(), name='transaction-log'),

    # --- Paiement Checkout ---
    path('payments/checkout/', CheckoutPaymentView.as_view(), name='payment-checkout'),
    
    # --- Boutique & Inventaire ---
    path('shop/items/', ShopItemListView.as_view(), name='shop-items-list'),
    path('shop/items/<int:pk>/', ShopItemDetailView.as_view(), name='shop-item-detail'),
    path('shop/items/<int:pk>/buy/', BuyItemView.as_view(), name='shop-item-buy'),
]