import random
from django.core.management.base import BaseCommand
from accounts.models import CustomUser, Badge  # Remplace 'users' par le nom exact de ton app

class Command(BaseCommand):
    help = 'Génère des utilisateurs de test et leur attribue des badges'

    def handle(self, *args, **kwargs):
        self.stdout.write("🚀 Lancement de la création des badges et utilisateurs...")

        # 1. Création des badges (si on relance le script, get_or_create évite les doublons)
        badges_data = [
            {"name": "Débutant 🥉", "description": "Nouveau sur la plateforme", "icon": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"},
            {"name": "Pro Vendeur 🥈", "description": "Plus de 50 produits trouvés", "icon": "https://cdn-icons-png.flaticon.com/512/3135/3135764.png"},
            {"name": "Expert 🥇", "description": "Maître du dropshipping", "icon": "https://cdn-icons-png.flaticon.com/512/3135/3135690.png"},
            {"name": "VIP 💎", "description": "Abonnement Premium Actif", "icon": "https://cdn-icons-png.flaticon.com/512/2950/2950660.png"},
        ]

        created_badges = []
        for b in badges_data:
            badge, _ = Badge.objects.get_or_create(
                name=b["name"],
                defaults={"description": b["description"], "icon_url": b["icon"]}
            )
            created_badges.append(badge)
            
        self.stdout.write(f"✅ {len(created_badges)} Badges prêts dans la base de données !")

        # 2. Création des utilisateurs
        users_data = [
            {"email": "amine@dropship.ma", "username": "amine_boss", "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Amine"},
            {"email": "sarah@ecom.fr", "username": "sarah_ecom", "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah"},
            {"email": "hustler@demo.com", "username": "hustler99", "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Hustler"},
        ]

        for u in users_data:
            # On vérifie si l'utilisateur n'existe pas déjà
            user, created = CustomUser.objects.get_or_create(
                email=u["email"],
                defaults={
                    "username": u["username"],
                    "avatar_url": u["avatar"],
                    "is_email_verified": True
                }
            )

            if created:
                # Il faut ABSOLUMENT utiliser set_password pour que le hash soit correct
                user.set_password("Pass1234!") 
                user.save()
                
                # 3. La magie du ManyToMany : on associe entre 1 et 3 badges au hasard
                random_badges = random.sample(created_badges, random.randint(1, 3))
                user.badges.add(*random_badges) # L'étoile (*) permet de passer une liste d'objets
                
                self.stdout.write(f"👤 Ajouté : {user.email} avec les badges -> {[b.name for b in random_badges]}")
            else:
                self.stdout.write(f"⚠️ {user.email} existe déjà, on passe.")

        self.stdout.write(self.style.SUCCESS("🎉 Base de données peuplée avec succès !"))