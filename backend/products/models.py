from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Product(models.Model):
    # --- TES CHAMPS DE BASE ---
    title = models.CharField(max_length=255, verbose_name="Titre du produit")
    description = models.TextField(blank=True, null=True, verbose_name="Description")
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="Prix d'achat (MAD)")
    aliexpress_url = models.URLField(max_length=1000, unique=True, verbose_name="Lien AliExpress")
    image_url = models.URLField(max_length=1000, blank=True, null=True, verbose_name="Lien de l'image principale")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Date d'ajout")

    # --- AJOUTS SIMPLES POUR TES FILTRES (Cahier des charges) ---
    category = models.CharField(max_length=100, blank=True, null=True, verbose_name="Catégorie (Niche)")
    competition_level = models.CharField(max_length=50, blank=True, null=True, verbose_name="Niveau de concurrence")
    video_url = models.URLField(max_length=1000, blank=True, null=True, verbose_name="Lien de la vidéo (Pub TikTok/FB)")

    # --- TES CHAMPS IA ET BUSINESS ---
    suggested_sale_price = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True, verbose_name="Prix de revente conseillé (MAD)"
    )
    potential_profit = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True, verbose_name="Profit estimé (MAD)"
    )
    trend_score = models.IntegerField(
        default=0, verbose_name="Score de tendance (0-100)"
    )
    is_winner = models.BooleanField(
        default=False, verbose_name="Produit Winner"
    )
    ai_analysis_summary = models.TextField(
        blank=True, null=True, verbose_name="Résumé de l'IA"
    )

    class Meta:
        verbose_name = "Produit"
        verbose_name_plural = "Produits"
        ordering = ['-created_at']

    def __str__(self):
        return self.title


#   Pour ajouter une fonctionnalité de "watchlist" ou "favoris" pour les utilisateurs, tu peux créer un modèle supplémentaire qui relie les utilisateurs aux produits qu'ils souhaitent surveiller. Voici un exemple de ce à quoi cela pourrait ressembler :
class ProductWatchlist(models.Model):
    """
    Indispensable pour ton Workflow 2 : Permet aux utilisateurs 
    d'ajouter un produit à leurs "favoris" pour le surveiller.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'product')
    

class AdCampaign(models.Model):
    PLATFORM_CHOICES = [('tiktok', 'TikTok'), ('facebook', 'Facebook'), ('instagram', 'Instagram')]
    
    title = models.CharField(max_length=255)
    product_link = models.URLField(blank=True, null=True)
    video_url = models.URLField()
    platform = models.CharField(max_length=20, choices=PLATFORM_CHOICES)
    ad_creative_text = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.platform} - {self.title}"
    
class ProductHistory(models.Model):
    """ Ligne 24 : Historique de consultation des produits """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='view_history')
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    viewed_at = models.DateTimeField(auto_now=True) 

    class Meta:
        ordering = ['-viewed_at']
        unique_together = ('user', 'product')