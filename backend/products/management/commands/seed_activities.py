import random
from datetime import timedelta
from django.utils import timezone
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

# Remplace 'nom_de_ton_app' par le vrai nom de l'application
from analytics.models import UserActivity

User = get_user_model()

class Command(BaseCommand):
    help = 'Génère un historique d\'activité réaliste pour tester le dashboard'

    def handle(self, *args, **kwargs):
        users = list(User.objects.all())

        if not users:
            self.stdout.write(self.style.ERROR("❌ Aucun utilisateur trouvé ! Lance d'abord 'python manage.py seed_users'"))
            return

        self.stdout.write("🚀 Lancement de la génération d'activités pour le Dashboard...")

        # --- Dictionnaire d'actions réalistes pour ton app ---
        # On utilise des fonctions (lambda) pour les détails afin que le JSON soit généré dynamiquement à chaque fois
        actions_pool = [
            {
                "action": "Connexion réussie",
                "get_details": lambda: {"device": random.choice(["iOS", "Android", "Web"]), "ip": f"192.168.1.{random.randint(10, 250)}"}
            },
            {
                "action": "Recherche de produit",
                "get_details": lambda: {"keyword": random.choice(["mini pc", "iphone case", "massage gun", "yoga mat"]), "filters": "US"}
            },
            {
                "action": "Ajout aux favoris",
                "get_details": lambda: {"product_name": random.choice(["Smartwatch Pro", "LED Desk Lamp", "Ergonomic Mouse"]), "platform": "AliExpress"}
            },
            {
                "action": "Calcul de rentabilité",
                "get_details": lambda: {"cost_mad": random.randint(50, 200), "suggested_price": random.randint(250, 600)}
            },
            {
                "action": "Participation Communauté",
                "get_details": lambda: {"post_type": random.choice(["Like", "Commentaire"]), "category": "SUCCESS"}
            }
        ]

        created_count = 0

        for user in users:
            # On génère entre 5 et 15 actions aléatoires par utilisateur
            num_actions = random.randint(5, 15)
            
            for _ in range(num_actions):
                action_template = random.choice(actions_pool)
                
                # 1. On crée l'action (Django va forcer created_at à MAINTENANT)
                activity = UserActivity.objects.create(
                    user=user,
                    action=action_template["action"],
                    details=action_template["get_details"]()
                )
                
                # 2. L'ASTUCE : On simule des dates passées (sur les 14 derniers jours)
                random_days_ago = random.randint(0, 14)
                random_hours_ago = random.randint(0, 23)
                random_minutes_ago = random.randint(0, 59)
                
                fake_date = timezone.now() - timedelta(days=random_days_ago, hours=random_hours_ago, minutes=random_minutes_ago)
                
                # On modifie la date en mémoire
                activity.created_at = fake_date
                # On force la sauvegarde EXCLUSIVEMENT sur ce champ pour contourner l'auto_now_add
                activity.save(update_fields=['created_at'])
                
                created_count += 1

        self.stdout.write(self.style.SUCCESS(f"🎉 Parfait ! {created_count} activités générées. Le endpoint de Fadwa est prêt à être nourri !"))