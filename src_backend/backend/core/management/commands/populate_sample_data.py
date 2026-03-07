"""
Management command to populate database with sample data
"""
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from core.models import UserProfile, Product, Favorite, TrendAlert
from decimal import Decimal
import random


class Command(BaseCommand):
    help = 'Populate database with sample data for testing'

    def add_arguments(self, parser):
        parser.add_argument(
            '--users',
            type=int,
            default=5,
            help='Number of sample users to create',
        )
        parser.add_argument(
            '--products',
            type=int,
            default=50,
            help='Number of sample products to create',
        )

    def handle(self, *args, **options):
        self.stdout.write('Starting data population...')
        
        # Create users
        users = self.create_users(options['users'])
        self.stdout.write(self.style.SUCCESS(f'Created {len(users)} users'))
        
        # Create products
        products = self.create_products(options['products'])
        self.stdout.write(self.style.SUCCESS(f'Created {len(products)} products'))
        
        # Create favorites
        favorites = self.create_favorites(users, products)
        self.stdout.write(self.style.SUCCESS(f'Created {len(favorites)} favorites'))
        
        # Create alerts
        alerts = self.create_alerts(users, products)
        self.stdout.write(self.style.SUCCESS(f'Created {len(alerts)} alerts'))
        
        self.stdout.write(self.style.SUCCESS('Data population completed!'))

    def create_users(self, count):
        users = []
        for i in range(count):
            username = f'user{i+1}'
            email = f'user{i+1}@example.com'
            
            user, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'email': email,
                    'first_name': f'User',
                    'last_name': f'{i+1}',
                }
            )
            
            if created:
                user.set_password('password123')
                user.save()
                
                # Create profile
                UserProfile.objects.create(
                    user=user,
                    subscription_plan=random.choice(['free', 'starter', 'pro', 'premium']),
                    profitability_score=random.randint(60, 95),
                )
            
            users.append(user)
        
        return users

    def create_products(self, count):
        products = []
        
        categories = ['tech', 'sport', 'home', 'fashion', 'beauty', 'toys', 'health']
        sources = ['aliexpress', 'amazon', 'shopify']
        
        product_names = [
            'Casque Sans-fil Premium', 'Montre Connectée Sport', 'Accessoires Téléphone',
            'Kit Fitness Maison', 'Lampe LED Intelligente', 'Organisateur Bureau',
            'Tapis de Yoga', 'Bouteille Sport', 'Écouteurs Bluetooth',
            'Support Téléphone Voiture', 'Chargeur Sans Fil', 'Câble USB-C',
            'Masque Visage LED', 'Brosse Nettoyante', 'Diffuseur Huiles',
            'Jouets Éducatifs', 'Puzzle 3D', 'Robot Jouet',
            'Vitamines Naturelles', 'Bande Résistance', 'Rouleau Massage',
        ]
        
        for i in range(count):
            name = random.choice(product_names)
            category = random.choice(categories)
            source = random.choice(sources)
            
            price = Decimal(random.uniform(15, 150))
            cost = price * Decimal(random.uniform(0.3, 0.6))
            profit = price - cost
            
            score = random.randint(60, 98)
            
            product, created = Product.objects.get_or_create(
                source_id=f'{source}_{i}',
                source=source,
                defaults={
                    'name': f'{name} {i+1}',
                    'description': f'Description détaillée pour {name}. Produit de haute qualité avec excellent rapport qualité-prix.',
                    'source_url': f'https://{source}.com/product/{i}',
                    'category': category,
                    'price': price,
                    'cost': cost,
                    'profit': profit,
                    'image_url': f'https://picsum.photos/400/400?random={i}',
                    'images': [f'https://picsum.photos/400/400?random={i}'],
                    'available_colors': random.sample(['beige', 'green', 'blue', 'pink', 'black'], k=random.randint(1, 3)),
                    'score': score,
                    'demand_level': random.randint(50, 100),
                    'popularity': random.randint(50, 100),
                    'competition': random.randint(30, 90),
                    'profitability': random.randint(60, 100),
                    'trend_percentage': Decimal(random.uniform(-20, 50)),
                    'is_trending': score >= 85 and random.random() > 0.5,
                    'supplier_name': f'{source.title()} Premium',
                    'supplier_rating': Decimal(random.uniform(4.0, 5.0)),
                    'supplier_review_count': random.randint(100, 5000),
                }
            )
            
            products.append(product)
        
        return products

    def create_favorites(self, users, products):
        favorites = []
        
        for user in users:
            # Each user favorites 3-8 random products
            num_favorites = random.randint(3, 8)
            user_products = random.sample(products, min(num_favorites, len(products)))
            
            for product in user_products:
                favorite, created = Favorite.objects.get_or_create(
                    user=user,
                    product=product
                )
                if created:
                    favorites.append(favorite)
        
        return favorites

    def create_alerts(self, users, products):
        alerts = []
        
        alert_templates = [
            {
                'type': 'category',
                'title': 'Tendance Sport & Fitness',
                'message': 'La catégorie "Sport & Fitness" connaît une hausse de 32% cette semaine',
            },
            {
                'type': 'product',
                'title': 'Produit en forte demande',
                'message': 'Ce produit a vu ses ventes augmenter de 45% cette semaine',
            },
            {
                'type': 'niche',
                'title': 'Nouvelle opportunité',
                'message': 'Une nouvelle niche prometteuse a été détectée dans la catégorie Tech',
            },
        ]
        
        for user in users:
            # Create 2-4 alerts per user
            num_alerts = random.randint(2, 4)
            
            for _ in range(num_alerts):
                template = random.choice(alert_templates)
                product = random.choice(products) if template['type'] == 'product' else None
                
                alert = TrendAlert.objects.create(
                    user=user,
                    alert_type=template['type'],
                    title=template['title'],
                    message=template['message'],
                    product=product,
                    is_read=random.random() > 0.5,
                )
                alerts.append(alert)
        
        return alerts
