#!/usr/bin/env python
"""
Script pour ajouter les champs nécessaires au modèle Product pour le scraping
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.db import connection

def add_scraper_fields():
    """Ajoute les champs nécessaires pour le scraping"""
    
    print("=" * 70)
    print("🔧 AJOUT DES CHAMPS DE SCRAPING AU MODÈLE PRODUCT")
    print("=" * 70)
    print()
    
    with connection.cursor() as cursor:
        # Liste des champs à ajouter
        fields_to_add = [
            ("external_id", "VARCHAR(200)", ""),
            ("product_url", "TEXT", ""),
            ("supplier", "VARCHAR(50)", "'aliexpress'"),
            ("original_price", "DECIMAL(10, 2)", "0"),
            ("rating", "DECIMAL(3, 2)", "0"),
            ("reviews_count", "INTEGER", "0"),
            ("orders_count", "INTEGER", "0"),
            ("shipping_cost", "DECIMAL(10, 2)", "0"),
            ("shipping_days", "INTEGER", "0"),
            ("stock", "INTEGER", "0"),
        ]
        
        for field_name, field_type, default_value in fields_to_add:
            try:
                # Vérifier si le champ existe déjà
                cursor.execute(f"SELECT {field_name} FROM core_product LIMIT 1")
                print(f"✓ Champ '{field_name}' existe déjà")
            except Exception:
                # Le champ n'existe pas, l'ajouter
                try:
                    if default_value:
                        sql = f"ALTER TABLE core_product ADD COLUMN {field_name} {field_type} DEFAULT {default_value}"
                    else:
                        sql = f"ALTER TABLE core_product ADD COLUMN {field_name} {field_type}"
                    
                    cursor.execute(sql)
                    print(f"✅ Champ '{field_name}' ajouté avec succès")
                except Exception as e:
                    print(f"❌ Erreur lors de l'ajout du champ '{field_name}': {e}")
    
    print()
    print("=" * 70)
    print("✅ MIGRATION TERMINÉE")
    print("=" * 70)
    print()
    print("💡 Vous pouvez maintenant exécuter:")
    print("   python import_products_auto.py")
    print()

if __name__ == '__main__':
    try:
        add_scraper_fields()
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
