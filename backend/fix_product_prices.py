#!/usr/bin/env python
"""
Script pour corriger les prix et profits des produits
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

def fix_product_prices():
    """Corrige les prix et profits des produits"""
    
    print("=" * 70)
    print("💰 CORRECTION DES PRIX ET PROFITS")
    print("=" * 70)
    print()
    
    products = Product.objects.all()
    fixed_count = 0
    
    print("🔧 Correction en cours...")
    print("-" * 70)
    
    for product in products:
        # Le prix actuel est en fait le coût d'achat
        cost = product.cost if product.cost else product.price
        
        # Calculer le nouveau prix de vente (250% du coût = marge de 150%)
        selling_price = cost * Decimal('2.5')
        
        # Calculer le profit (Prix de vente - Coût)
        profit = selling_price - cost
        
        # Mettre à jour
        product.cost = cost
        product.price = selling_price
        product.profit = profit
        product.save()
        
        fixed_count += 1
        
        print(f"✅ {product.name[:50]}")
        print(f"   Coût:   {cost:.2f}€")
        print(f"   Vente:  {selling_price:.2f}€")
        print(f"   Profit: {profit:.2f}€")
        print(f"   Marge:  {((profit / cost) * 100):.0f}%")
        print()
    
    print("=" * 70)
    print(f"✅ {fixed_count} produits corrigés")
    print("=" * 70)
    print()
    
    # Afficher quelques exemples
    print("📊 EXEMPLES DE PRODUITS CORRIGÉS")
    print("-" * 70)
    
    examples = Product.objects.order_by('-score')[:5]
    for product in examples:
        print(f"• {product.name[:40]}")
        print(f"  Coût: {product.cost:.2f}€ → Vente: {product.price:.2f}€ → Profit: {product.profit:.2f}€")
    
    print()
    print("=" * 70)
    print("✅ CORRECTION TERMINÉE!")
    print("=" * 70)
    print()
    print("💡 Maintenant:")
    print("   Prix = Prix de vente au client")
    print("   Profit = Bénéfice net (Prix - Coût)")
    print("   Coût = Prix d'achat fournisseur")
    print()
    print("📱 Rechargez l'application pour voir les changements!")
    print()

if __name__ == '__main__':
    try:
        fix_product_prices()
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
