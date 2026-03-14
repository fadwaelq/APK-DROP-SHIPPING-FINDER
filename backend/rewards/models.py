import uuid
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class RewardProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='reward_profile')
    referral_code = models.CharField(max_length=20, unique=True, blank=True)
    points = models.IntegerField(default=0)

    def save(self, *args, **kwargs):
        # Génère un code de parrainage unique automatiquement à la création
        if not self.referral_code:
            # Ex: Si le pseudo est "DIABATE", le code sera "DIA-A1B2C"
            prefix = self.user.username[:3].upper() if self.user.username else "USR"
            random_str = str(uuid.uuid4())[:5].upper()
            self.referral_code = f"{prefix}-{random_str}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user.username} - {self.points} pts (Code: {self.referral_code})"

class Referral(models.Model):
    referrer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='referrals_made')
    referred_user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='referred_by')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.referrer.username} a parrainé {self.referred_user.username}"