import uuid
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class RewardProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='reward_profile')
    referral_code = models.CharField(max_length=20, unique=True, blank=True)
    
    # --- AJOUTS POUR XP & NIVEAUX ---
    total_xp = models.PositiveIntegerField(default=0)
    current_level = models.PositiveIntegerField(default=1)
    # -------------------------------

    def save(self, *args, **kwargs):
        if not self.referral_code:
            prefix = self.user.username[:3].upper() if self.user.username else "USR"
            random_str = str(uuid.uuid4())[:5].upper()
            self.referral_code = f"{prefix}-{random_str}"
        super().save(*args, **kwargs)

    @property
    def xp_required_for_next_level(self):
        # Logique : Niveau 1 demande 100 XP, Niveau 2 demande 200 XP, etc.
        return self.current_level * 100

    def __str__(self):
        return f"{self.user.username} - Niv. {self.current_level} ({self.total_xp} XP)"
        
    # Calcul du niveau en fonction de l'XP totale et de l'XP requis pour le niveau suivant
    def add_xp(self, amount):
        self.total_xp += amount
        # Tant que l'XP dépasse le requis, on monte d'un niveau
        while self.total_xp >= self.xp_required_for_next_level:
            self.current_level += 1
        self.save()
        return self.current_level

# Pour les missions, on peut créer un modèle Mission et un modèle UserMissionLog pour suivre les missions validées par l'utilisateur.
class Mission(models.Model):
    MISSION_TYPES = (('DAILY', 'Quotidienne'), ('WEEKLY', 'Hebdomadaire'))
    title = models.CharField(max_length=255)
    description = models.TextField()
    mission_type = models.CharField(max_length=10, choices=MISSION_TYPES)
    reward_xp = models.PositiveIntegerField(default=10)
    reward_coins = models.PositiveIntegerField(default=5)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"[{self.mission_type}] {self.title}"

#  User Mission pour suivre les missions validées par l'utilisateur
class UserMissionLog(models.Model):
    """ Empêche de valider la même mission plusieurs fois """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='mission_logs')
    mission = models.ForeignKey(Mission, on_delete=models.CASCADE)
    completed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-completed_at']

class Referral(models.Model):
    referrer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='referrals_made')
    referred_user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='referred_by')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.referrer.username} a parrainé {self.referred_user.username}"