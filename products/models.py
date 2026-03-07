from django.db import models

class Product(models.Model):
    # Champs de base (déjà présents)
    title = models.CharField(max_length=255, verbose_name="Titre du produit")
    description = models.TextField(blank=True, null=True, verbose_name="Description")
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="Prix d'achat (€)")
    aliexpress_url = models.URLField(max_length=1000, unique=True, verbose_name="Lien AliExpress")
    image_url = models.URLField(max_length=1000, blank=True, null=True, verbose_name="Lien de l'image principale")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Date d'ajout")

    # --- NOUVEAUX CHAMPS POUR L'IA ET LE BUSINESS ---
    suggested_sale_price = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True, verbose_name="Prix de revente conseillé (€)"
    )
    potential_profit = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True, verbose_name="Profit estimé (€)"
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