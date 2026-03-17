from django.db import models
from django.contrib.auth import get_user_model

# On récupère ton modèle utilisateur personnalisé (accounts)
User = get_user_model()

class UserActivity(models.Model):
    """
    Modèle pour tracer l'historique et l'activité des utilisateurs.
    Répond à l'exigence du frontend : GET /api/dashboard/recent-activity
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='activities')
    action = models.CharField(max_length=255, help_text="Ex: 'Recherche de produit', 'Connexion', 'Ajout favori'")
    details = models.JSONField(null=True, blank=True, help_text="Données supplémentaires (ex: mots-clés recherchés)")
    
    # Le champ created_at est explicitement demandé dans le cahier des charges de Fadwa
    created_at = models.DateTimeField(auto_now_add=True) 

    class Meta:
        ordering = ['-created_at'] # Les plus récents en premier
        verbose_name = "Activité Utilisateur"
        verbose_name_plural = "Activités Utilisateurs"

    def __str__(self):
        return f"{self.user.username} - {self.action} ({self.created_at.strftime('%Y-%m-%d %H:%M')})"