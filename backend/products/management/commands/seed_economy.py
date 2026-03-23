import random
from datetime import timedelta
from django.utils import timezone
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

# Remplace 'nom_de_ton_app' par le vrai nom de l'application !
from economy.models import UserWallet, CoinTransaction, ShopItem, UserInventory

User = get_user_model()

class Command(BaseCommand):
    help = 'Génère la boutique, les portefeuilles, les transactions et les achats des utilisateurs'

    def handle(self, *args, **kwargs):
        users = list(User.objects.all())

        if not users:
            self.stdout.write(self.style.ERROR("❌ Aucun utilisateur trouvé ! Lance d'abord 'python manage.py seed_users'"))
            return

        self.stdout.write("🚀 Lancement de la génération de l'économie (Boutique & Wallets)...")

        # --- 1. CRÉATION DES ARTICLES DE LA BOUTIQUE (ShopItem) ---
        shop_items_data = [
            {"name": "Avatar Premium 3D", "desc": "Démarque-toi avec un avatar exclusif animé.", "price": 500, "icon": "https://cdn-icons-png.flaticon.com/512/4140/4140048.png"},
            {"name": "Badge 'Top Vendeur'", "desc": "Affiche ton autorité sur tes posts communautaires.", "price": 1000, "icon": "https://cdn-icons-png.flaticon.com/512/5610/5610944.png"},
            {"name": "Boost Visibilité (24h)", "desc": "Mets ton profil ou ton post en avant pendant 24h.", "price": 300, "icon": "https://cdn-icons-png.flaticon.com/512/1085/1085694.png"},
            {"name": "E-book: 50 Produits Winner", "desc": "Accès immédiat au PDF des meilleurs produits du trimestre.", "price": 1500, "icon": "https://cdn-icons-png.flaticon.com/512/2232/2232688.png"},
        ]

        created_items = []
        for item in shop_items_data:
            shop_item, _ = ShopItem.objects.get_or_create(
                name=item["name"],
                defaults={
                    "description": item["desc"],
                    "price": item["price"],
                    "image_url": item["icon"],
                    "is_active": True
                }
            )
            created_items.append(shop_item)
            
        self.stdout.write(f"✅ {len(created_items)} articles ajoutés à la Boutique !")

        # --- 2. GESTION DES WALLETS ET TRANSACTIONS POUR CHAQUE UTILISATEUR ---
        for user in users:
            # Créer ou récupérer le wallet
            wallet, _ = UserWallet.objects.get_or_create(user=user)
            # On réinitialise à 0 pour recalculer proprement si on relance le script
            wallet.balance = 0 
            
            # A. Simuler des GAINS (EARN)
            earn_sources = [
                ("signup_bonus", "Bonus de bienvenue", 500),
                ("daily_login", "Connexion quotidienne", 50),
                ("referral", "Parrainage d'un ami", 200),
                ("mission", "Mission complétée : Trouver 5 produits", 100)
            ]
            
            # On lui donne entre 3 et 6 gains
            num_earns = random.randint(3, 6)
            for _ in range(num_earns):
                source, desc, base_amount = random.choice(earn_sources)
                amount = base_amount + random.randint(0, 50) # Petite variation
                
                t_earn = CoinTransaction.objects.create(
                    user=user,
                    transaction_type='EARN',
                    amount=amount,
                    source=source,
                    description=desc
                )
                
                # Astuce pour backdater la transaction (entre 1 et 10 jours)
                fake_date = timezone.now() - timedelta(days=random.randint(1, 10), hours=random.randint(1, 23))
                t_earn.timestamp = fake_date
                t_earn.save(update_fields=['timestamp'])
                
                wallet.balance += amount

            # B. Simuler des DÉPENSES (Achats dans la boutique)
            # On essaie de lui faire acheter 1 ou 2 objets s'il a assez de coins
            num_purchases = random.randint(1, 2)
            items_to_buy = random.sample(created_items, num_purchases)
            
            for item in items_to_buy:
                # Vérifie s'il a assez d'argent ET s'il ne possède pas déjà l'objet
                if wallet.balance >= item.price and not UserInventory.objects.filter(user=user, item=item).exists():
                    # 1. Créer la transaction de dépense
                    t_spend = CoinTransaction.objects.create(
                        user=user,
                        transaction_type='SPEND',
                        amount=item.price,
                        source="achat_boutique",
                        description=f"Achat de l'article : {item.name}"
                    )
                    
                    # 2. Ajouter l'objet à l'inventaire
                    inventory_item = UserInventory.objects.create(user=user, item=item)
                    
                    # Backdater l'achat et la transaction
                    fake_buy_date = timezone.now() - timedelta(hours=random.randint(1, 20))
                    t_spend.timestamp = fake_buy_date
                    t_spend.save(update_fields=['timestamp'])
                    
                    inventory_item.purchased_at = fake_buy_date
                    inventory_item.save(update_fields=['purchased_at'])
                    
                    # 3. Déduire du solde
                    wallet.balance -= item.price
            
            # Sauvegarder le solde final du wallet
            wallet.save()

        self.stdout.write(self.style.SUCCESS("🎉 Wallets remplis, historique généré et inventaires mis à jour !"))