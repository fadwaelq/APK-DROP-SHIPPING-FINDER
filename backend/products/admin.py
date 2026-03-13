from django.contrib import admin
from .models import Product, ProductWatchlist

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    # Les colonnes visibles dans la liste des produits
    list_display = ('title', 'price', 'category', 'trend_score', 'is_winner', 'created_at')
    
    # Barre de recherche très puissante (recherche par titre, lien ou catégorie)
    search_fields = ('title', 'aliexpress_url', 'category')
    
    # Filtres sur le côté droit pour trier rapidement tes produits
    list_filter = ('is_winner', 'category', 'competition_level', 'created_at')
    
    # Rendre la date de création non modifiable
    readonly_fields = ('created_at',)
    
    # Organiser le formulaire d'édition par sections
    fieldsets = (
        ('Informations de base', {
            'fields': ('title', 'description', 'category', 'image_url', 'video_url', 'aliexpress_url')
        }),
        ('Finances & Business (MAD)', {
            'fields': ('price', 'suggested_sale_price', 'potential_profit')
        }),
        ('Intelligence Artificielle', {
            'fields': ('trend_score', 'competition_level', 'is_winner', 'ai_analysis_summary')
        }),
        ('Métadonnées', {
            'fields': ('created_at',),
        }),
    )

@admin.register(ProductWatchlist)
class ProductWatchlistAdmin(admin.ModelAdmin):
    # Affichage de la Watchlist
    list_display = ('user', 'product', 'added_at')
    
    # Permet de filtrer par date d'ajout
    list_filter = ('added_at',)
    
    # Permet de chercher par l'email de l'utilisateur ou le titre du produit
    search_fields = ('user__email', 'product__title')
    
    readonly_fields = ('added_at',)