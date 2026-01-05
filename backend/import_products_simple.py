#!/usr/bin/env python
"""
Script simplifié pour importer des produits en utilisant les champs existants
"""
import os
import sys
import django
from decimal import Decimal

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product
from core.scrapers.aliexpress_scraper import AliExpressScraper


def map_category(scraper_category):
    """Map scraper categories to model categories"""
    mapping = {
        'electronics': 'tech',
        'fashion': 'fashion',
        'home': 'home',
        'beauty': 'beauty',
        'sports': 'sport',
        'toys': 'toys',
        'automotive': 'tech',
        'jewelry': 'fashion',
    }
    return mapping.get(scraper_category, 'tech')


def import_products():
    """Importe les produits depuis le scraper"""
    
    print("=" * 70)
    print("🤖 IMPORT AUTOMATIQUE DE PRODUITS")
    print("=" * 70)
    print()
    
    # Initialiser le scraper
    print("📡 Initialisation du scraper AliExpress...")
    scraper = AliExpressScraper()
    
    # Scraper les produits
    print("🔍 Scraping des produits en cours...")
    products = scraper.scrape()
    print(f"✅ {len(products)} produits trouvés\n")
    
    # Statistiques
    created_count = 0
    updated_count = 0
    skipped_count = 0
    
    print("💾 Import dans la base de données...")
    print("-" * 70)
    
    for product_data in products:
        try:
            # Chercher si le produit existe déjà par nom
            existing = Product.objects.filter(name=product_data['name']).first()
            
            # Mapper les données aux champs du modèle existant
            cost = Decimal(str(product_data['price']))  # Coût d'achat
            selling_price = cost * Decimal('2.5')  # Prix de vente (250% du coût)
            profit = selling_price - cost  # Profit = Prix de vente - Coût
            
            product_dict = {
                'name': product_data['name'],
                'description': product_data.get('description', ''),
                'price': selling_price,  # Prix de vente au client
                'cost': cost,  # Coût d'achat fournisseur
                'profit': profit,  # Bénéfice net
                'category': map_category(product_data.get('category', 'tech')),
                'image_url': product_data.get('image_url', ''),
                'source': 'aliexpress',
                'source_url': product_data.get('product_url', ''),
                'source_id': product_data.get('external_id', ''),
                'supplier_name': 'AliExpress Official',
                'supplier_rating': Decimal(str(product_data.get('rating', 4.5))),
                'supplier_review_count': product_data.get('reviews_count', 0),
                'score': product_data.get('score', 0),
                'is_trending': product_data.get('score', 0) >= 80,
                'demand_level': min(100, product_data.get('orders_count', 0) // 100),
                'popularity': min(100, product_data.get('reviews_count', 0) // 50),
                'profitability': product_data.get('score', 0),
            }
            
            if existing:
                # Mettre à jour le produit existant
                for key, value in product_dict.items():
                    setattr(existing, key, value)
                existing.save()
                updated_count += 1
                status = "🔄 MIS À JOUR"
            else:
                # Créer un nouveau produit
                Product.objects.create(**product_dict)
                created_count += 1
                status = "✅ CRÉÉ"
            
            print(f"{status}: {product_data['name'][:50]}")
            print(f"   Score: {product_data['score']}/100 | Prix: {product_data['price']}€ | Catégorie: {product_dict['category']}")
            
        except Exception as e:
            skipped_count += 1
            print(f"❌ ERREUR: {product_data['name'][:50]}")
            print(f"   {str(e)}")
    
    print()
    print("=" * 70)
    print("📊 RÉSUMÉ DE L'IMPORT")
    print("=" * 70)
    print(f"✅ Créés:      {created_count}")
    print(f"🔄 Mis à jour: {updated_count}")
    print(f"❌ Ignorés:    {skipped_count}")
    print(f"📦 Total:      {created_count + updated_count + skipped_count}")
    print()
    
    # Afficher les statistiques globales
    total_products = Product.objects.count()
    avg_score = Product.objects.aggregate(avg_score=django.db.models.Avg('score'))['avg_score'] or 0
    
    print("📈 STATISTIQUES GLOBALES")
    print("-" * 70)
    print(f"Total produits en base: {total_products}")
    print(f"Score moyen:            {avg_score:.1f}/100")
    print()
    
    # Top 5 produits par score
    print("🏆 TOP 5 NOUVEAUX PRODUITS PAR SCORE")
    print("-" * 70)
    top_products = Product.objects.filter(source='aliexpress').order_by('-score')[:5]
    for i, product in enumerate(top_products, 1):
        print(f"{i}. {product.name[:50]}")
        print(f"   Score: {product.score}/100 | Prix: {product.price}€ | {product.category}")
    
    print()
    print("=" * 70)
    print("✅ IMPORT TERMINÉ AVEC SUCCÈS!")
    print("=" * 70)
    print()
    print("💡 Prochaines étapes:")
    print("   1. Vérifiez les produits dans l'admin: http://localhost:8000/admin")
    print("   2. Testez l'application: http://localhost:3000")
    print("   3. Les nouveaux produits apparaîtront dans 'Produits Tendance'")
    print()


if __name__ == '__main__':
    try:
        import_products()
    except Exception as e:
        print(f"\n❌ ERREUR CRITIQUE: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
