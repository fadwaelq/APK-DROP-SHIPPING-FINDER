#!/usr/bin/env python
"""
Importer de vrais produits depuis AliExpress avec de vraies images
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from integrations.aliexpress_connector import AliExpressConnector
from core.models import Product
from decimal import Decimal
import random

def import_real_products():
    """Importer de vrais produits avec vraies images depuis AliExpress"""
    
    print("=" * 60)
    print("🚀 Import de Produits Réels depuis AliExpress")
    print("=" * 60)
    print()
    
    # Catégories à importer
    categories = {
        'tech': ['wireless earbuds', 'led strip lights', 'phone charger'],
        'sport': ['resistance bands', 'smart watch'],
        'home': ['essential oil diffuser', 'kitchen organizer'],
        'fashion': ['handbag', 'sunglasses'],
        'beauty': ['makeup brushes', 'led face mask'],
        'toys': ['drone camera'],
        'health': ['thermometer infrared']
    }
    
    connector = AliExpressConnector(use_tor=False)
    
    # Supprimer les anciens produits
    old_count = Product.objects.count()
    Product.objects.all().delete()
    print(f"🗑️  {old_count} anciens produits supprimés\n")
    
    total_imported = 0
    
    for category, queries in categories.items():
        print(f"\n📦 Catégorie: {category.upper()}")
        print("-" * 60)
        
        for query in queries:
            print(f"   🔍 Recherche: '{query}'...")
            
            try:
                # Rechercher sur AliExpress
                products_data = connector.search_products(query, max_results=2)
                
                if not products_data:
                    print(f"      ⚠️  Aucun produit trouvé")
                    continue
                
                # Créer les produits en base
                for product_data in products_data:
                    try:
                        # Normaliser les données
                        normalized = connector.normalize_product(product_data)
                        
                        # Ajouter la catégorie
                        normalized['category'] = category
                        
                        # Créer le produit
                        product = Product.objects.create(**normalized)
                        total_imported += 1
                        
                        print(f"      ✅ {product.name[:50]}... (Score: {product.score})")
                        
                    except Exception as e:
                        print(f"      ❌ Erreur création: {e}")
                        continue
                        
            except Exception as e:
                print(f"      ❌ Erreur recherche: {e}")
                continue
    
    print()
    print("=" * 60)
    print(f"✅ Import Terminé!")
    print("=" * 60)
    print(f"📊 {total_imported} produits importés avec de vraies images")
    print(f"🔥 {Product.objects.filter(is_trending=True).count()} produits tendance")
    print()
    
    # Afficher quelques exemples
    print("📸 Exemples d'images importées:")
    for product in Product.objects.all()[:5]:
        print(f"   • {product.name[:40]}...")
        print(f"     Image: {product.image_url[:80]}...")
    
    print()
    print("=" * 60)
    print("🎉 Les produits ont maintenant de vraies images!")
    print("👉 Rechargez l'application: http://localhost:3000")
    print("=" * 60)

if __name__ == '__main__':
    import_real_products()
