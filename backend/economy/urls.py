from django.urls import path
from .views import BuyItemView, CheckoutPaymentView, CoinBalanceView, CoinHistoryView, EarnCoinsView, ShopItemDetailView, ShopItemListView, SpendCoinsView

urlpatterns = [
    path('user/coins-balance/', CoinBalanceView.as_view(), name='coins-balance'),
    path('user/coins-history/', CoinHistoryView.as_view(), name='coins-history'),
    path('user/coins/earn/', EarnCoinsView.as_view(), name='coins-earn'),
    path('user/coins/spend/', SpendCoinsView.as_view(), name='coins-spend'),
    path('payments/checkout/', CheckoutPaymentView.as_view(), name='payment-checkout'),
    path('api/shop/items/', ShopItemListView.as_view(), name='shop-items-list'),
    path('api/shop/items/<int:pk>/', ShopItemDetailView.as_view(), name='shop-item-detail'),
    path('api/shop/items/<int:pk>/buy/', BuyItemView.as_view(), name='shop-item-buy'),
    
]