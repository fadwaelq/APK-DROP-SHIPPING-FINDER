from django.contrib import admin
from .models import UserInventory, UserWallet, CoinTransaction,ShopItem

@admin.register(UserWallet)
class UserWalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'balance', 'last_update')
    search_fields = ('user__username',)

@admin.register(CoinTransaction)
class CoinTransactionAdmin(admin.ModelAdmin):
    list_display = ('user', 'transaction_type', 'amount', 'source', 'timestamp')
    list_filter = ('transaction_type', 'source')
    search_fields = ('user__username', 'description')



@admin.register(ShopItem)
class ShopItemAdmin(admin.ModelAdmin):
    list_display = ['name', 'price', 'is_active']

@admin.register(UserInventory)
class UserInventoryAdmin(admin.ModelAdmin):
    list_display = ['user', 'item', 'purchased_at']
    search_fields = ['user__username', 'item__name']