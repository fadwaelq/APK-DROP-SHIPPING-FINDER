#!/usr/bin/env python
"""
Script pour ajouter des favoris de test à un utilisateur
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import Product, Favorite

def add_test_favorites():
    """Ajoute des favoris de test pour l'utilisateur latifa"""
    
    print("🎯 Ajout de favoris de test")
    print("=" * 60)
    
    # Récupérer l'utilisateur
    try:
        user = User.objects.get(email="erradilatifa6@gmail.com")
        print(f"✅ Utilisateur trouvé: {user.username} (ID: {user.id})")
    except User.DoesNotExist:
        print("❌ Utilisateur non trouvé!")
        return
    
    # Récupérer quelques produits
    products = Product.objects.all()[:5]
    
    if not products:
        print("❌ Aucun produit trouvé dans la base de données!")
        print("   Veuillez d'abord créer des produits.")
        return
    
    print(f"\n📦 Produits disponibles: {products.count()}")
    print()
    
    # Supprimer les anciens favoris
    old_favorites = Favorite.objects.filter(user=user)
    old_count = old_favorites.count()
    old_favorites.delete()
    print(f"🗑️  Supprimé {old_count} ancien(s) favori(s)")
    print()
    
    # Ajouter les nouveaux favoris
    favorites_added = 0
    for product in products:
        favorite, created = Favorite.objects.get_or_create(
            user=user,
            product=product
        )
        if created:
            favorites_added += 1
            print(f"✅ Ajouté: {product.name}")
            print(f"   Score: {product.score} | Prix: {product.price}€")
    
    print()
    print("=" * 60)
    print(f"✅ {favorites_added} favoris ajoutés pour {user.username}")
    print()
    print("📊 Résumé:")
    print(f"   User ID: {user.id}")
    print(f"   Username: {user.username}")
    print(f"   Email: {user.email}")
    print(f"   Favoris: {Favorite.objects.filter(user=user).count()}")
    print()
    print("=" * 60)
    print("🎉 Vous pouvez maintenant vous connecter et voir vos favoris!")
    print()
    print("📱 Dans l'application:")
    print("   1. Connectez-vous avec erradilatifa6@gmail.com / latifa123")
    print("   2. Allez dans 'Mes Favoris'")
    print(f"   3. Vous devriez voir {favorites_added} produits")

if __name__ == '__main__':
    try:
        add_test_favorites()
    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
