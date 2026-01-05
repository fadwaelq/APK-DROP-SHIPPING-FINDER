#!/usr/bin/env python
"""
Script pour importer automatiquement des produits depuis les scrapers
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


def import_products_from_scraper():
    """Importe les produits depuis le scraper AliExpress"""
    
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
            # Vérifier si le produit existe déjà
            external_id = product_data.get('external_id')
            
            if external_id:
                # Chercher par external_id
                existing = Product.objects.filter(external_id=external_id).first()
            else:
                # Chercher par nom
                existing = Product.objects.filter(name=product_data['name']).first()
            
            # Préparer les données
            product_dict = {
                'name': product_data['name'],
                'description': product_data.get('description', ''),
                'price': Decimal(str(product_data['price'])),
                'original_price': Decimal(str(product_data.get('original_price', product_data['price']))),
                'category': product_data.get('category', 'general'),
                'image_url': product_data.get('image_url', ''),
                'product_url': product_data.get('product_url', ''),
                'supplier': product_data.get('supplier', 'aliexpress'),
                'external_id': product_data.get('external_id', ''),
                'score': product_data.get('score', 0),
                'rating': Decimal(str(product_data.get('rating', 0))),
                'reviews_count': product_data.get('reviews_count', 0),
                'orders_count': product_data.get('orders_count', 0),
                'shipping_cost': Decimal(str(product_data.get('shipping_cost', 0))),
                'shipping_days': product_data.get('shipping_days', 0),
                'stock': product_data.get('stock', 0),
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
            print(f"   Score: {product_data['score']}/100 | Prix: {product_data['price']}€ | Commandes: {product_data.get('orders_count', 0)}")
            
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
    print("🏆 TOP 5 PRODUITS PAR SCORE")
    print("-" * 70)
    top_products = Product.objects.order_by('-score')[:5]
    for i, product in enumerate(top_products, 1):
        print(f"{i}. {product.name[:50]}")
        print(f"   Score: {product.score}/100 | Prix: {product.price}€ | {product.supplier}")
    
    print()
    print("=" * 70)
    print("✅ IMPORT TERMINÉ AVEC SUCCÈS!")
    print("=" * 70)
    print()
    print("💡 Prochaines étapes:")
    print("   1. Vérifiez les produits dans l'admin: http://localhost:8000/admin")
    print("   2. Testez l'application: http://localhost:3000")
    print("   3. Configurez un cron job pour l'import automatique quotidien")
    print()


if __name__ == '__main__':
    try:
        import_products_from_scraper()
    except Exception as e:
        print(f"\n❌ ERREUR CRITIQUE: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
