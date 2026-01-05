import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

print("=== VÉRIFICATION CATÉGORIE MAISON ===\n")

# Vérifier tous les produits
all_products = Product.objects.all()
print(f"Total produits: {all_products.count()}\n")

# Vérifier catégorie 'home'
home_products = Product.objects.filter(category='home')
print(f"Produits avec category='home': {home_products.count()}")
for p in home_products:
    print(f"  - {p.name} (category={p.category})")

print()

# Vérifier catégorie 'maison'
maison_products = Product.objects.filter(category='maison')
print(f"Produits avec category='maison': {maison_products.count()}")
for p in maison_products:
    print(f"  - {p.name} (category={p.category})")

print()

# Afficher toutes les catégories
categories = Product.objects.values_list('category', flat=True).distinct()
print("Catégories dans la base:")
for cat in categories:
    count = Product.objects.filter(category=cat).count()
    print(f"  - {cat}: {count} produits")
