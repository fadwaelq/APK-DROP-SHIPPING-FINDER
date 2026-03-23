import random
from datetime import timedelta
from django.utils import timezone
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

# Remplace 'nom_de_ton_app' par le vrai nom de ton application !
from rewards.models import RewardProfile, Mission, UserMissionLog, Referral

User = get_user_model()

class Command(BaseCommand):
    help = 'Génère les profils de récompense (XP), les missions et les parrainages'

    def handle(self, *args, **kwargs):
        users = list(User.objects.all())

        if not users:
            self.stdout.write(self.style.ERROR("❌ Aucun utilisateur trouvé ! Lance d'abord 'python manage.py seed_users'"))
            return

        self.stdout.write("🚀 Lancement de la génération du système de Récompenses (XP, Niveaux, Missions)...")

        # --- 1. CRÉATION DES MISSIONS ---
        missions_data = [
            {"title": "Chercheur d'Or", "desc": "Analyse 5 produits avec le calculateur de marge.", "type": "DAILY", "xp": 50, "coins": 10},
            {"title": "Social", "desc": "Laisse un commentaire constructif sur le post d'un autre membre.", "type": "DAILY", "xp": 20, "coins": 5},
            {"title": "L'Oeil du Tigre", "desc": "Connecte-toi 5 jours d'affilée (Streak de 5).", "type": "WEEKLY", "xp": 150, "coins": 50},
            {"title": "Loup de Wall Street", "desc": "Ajoute 10 produits à tes favoris.", "type": "WEEKLY", "xp": 100, "coins": 30},
        ]

        created_missions = []
        for m in missions_data:
            mission, _ = Mission.objects.get_or_create(
                title=m["title"],
                defaults={
                    "description": m["desc"],
                    "mission_type": m["type"],
                    "reward_xp": m["xp"],
                    "reward_coins": m["coins"]
                }
            )
            created_missions.append(mission)
            
        self.stdout.write(f"✅ {len(created_missions)} Missions créées avec succès !")

        # --- 2. PROFILS DE RÉCOMPENSES & VALIDATION DE MISSIONS ---
        for user in users:
            # Création du profil (le code de parrainage se génère tout seul grâce à ta méthode save())
            profile, created = RewardProfile.objects.get_or_create(user=user)

            # Simuler un peu d'activité (Streak et date)
            profile.current_streak = random.randint(0, 15)
            profile.last_activity_date = timezone.now().date() - timedelta(days=random.randint(0, 2))

            # On lui donne de l'XP aléatoire. 
            # Ta fonction add_xp() est géniale car elle gère le level up toute seule !
            random_xp = random.randint(50, 800) 
            profile.add_xp(random_xp) 

            # Simuler la complétion de 1 à 3 missions au hasard
            missions_to_complete = random.sample(created_missions, random.randint(1, 3))
            for mission in missions_to_complete:
                # Vérifier si l'utilisateur n'a pas déjà validé cette mission
                if not UserMissionLog.objects.filter(user=user, mission=mission).exists():
                    log = UserMissionLog.objects.create(user=user, mission=mission)

                    # L'astuce habituelle pour antidater la complétion (auto_now_add)
                    fake_date = timezone.now() - timedelta(days=random.randint(0, 6), hours=random.randint(1, 23))
                    log.completed_at = fake_date
                    log.save(update_fields=['completed_at'])

        self.stdout.write("✅ Profils mis à jour (XP & Niveaux calculés) et Missions accomplies !")

        # --- 3. SYSTÈME DE PARRAINAGE (REFERRALS) ---
        if len(users) >= 2:
            # On prend le premier utilisateur comme le grand parrain (ex: toi)
            referrer = users[0]
            # On prend 1 ou 2 autres utilisateurs pour être ses filleuls
            referred_users = users[1:min(len(users), 3)]

            for referred in referred_users:
                # On s'assure qu'il n'est pas déjà parrainé (OneToOneField l'exige)
                if getattr(referred, 'referred_by', None) is None:
                    referral = Referral.objects.create(referrer=referrer, referred_user=referred)
                    
                    # Antidater le parrainage
                    fake_ref_date = timezone.now() - timedelta(days=random.randint(5, 30))
                    referral.created_at = fake_ref_date
                    referral.save(update_fields=['created_at'])

            self.stdout.write(f"✅ Système de parrainage généré (ex: {referrer.username} a parrainé {len(referred_users)} membres) !")

        self.stdout.write(self.style.SUCCESS("🎉 Système de XP, Niveaux et Missions prêt !"))