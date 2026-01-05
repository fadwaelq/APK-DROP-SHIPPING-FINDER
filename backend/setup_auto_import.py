#!/usr/bin/env python
"""
Configuration de l'import automatique de produits
Conforme au Cahier des Charges - Section 4.5
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django_celery_beat.models import PeriodicTask, IntervalSchedule
import json

def setup_automatic_imports():
    """
    Configure les tâches automatiques d'import de produits
    Selon le cahier des charges:
    - Produits populaires: refresh toutes les 6-12h
    - Catalogue général: refresh 24-72h
    - Alertes en quasi-temps réel
    """
    
    print("=" * 60)
    print("🚀 Configuration de l'Import Automatique de Produits")
    print("=" * 60)
    print("\nSelon le Cahier des Charges (Section 4.5):")
    print("- Produits populaires: toutes les 6-12 heures")
    print("- Catalogue général: toutes les 24-72 heures")
    print("- Alertes tendances: temps réel")
    print()
    
    # 1. Créer les intervalles de temps
    print("📅 Création des intervalles...")
    
    # Toutes les 6 heures (produits populaires)
    schedule_6h, _ = IntervalSchedule.objects.get_or_create(
        every=6,
        period=IntervalSchedule.HOURS,
    )
    
    # Toutes les 24 heures (catalogue général)
    schedule_24h, _ = IntervalSchedule.objects.get_or_create(
        every=24,
        period=IntervalSchedule.HOURS,
    )
    
    # Toutes les heures (mise à jour scores)
    schedule_1h, _ = IntervalSchedule.objects.get_or_create(
        every=1,
        period=IntervalSchedule.HOURS,
    )
    
    print("✅ Intervalles créés")
    
    # 2. Tâche: Import produits tendance (toutes les 6h)
    print("\n🔥 Configuration: Import Produits Tendance (6h)...")
    
    PeriodicTask.objects.update_or_create(
        name='Import Produits Tendance',
        defaults={
            'task': 'integrations.sync_trending_products',
            'interval': schedule_6h,
            'args': json.dumps([]),
            'kwargs': json.dumps({
                'categories': [
                    'phone accessories',
                    'smart watch',
                    'wireless earbuds',
                    'led lights',
                    'home decor',
                    'fitness equipment',
                    'beauty products',
                    'pet supplies'
                ],
                'use_tor': True
            }),
            'enabled': True,
        }
    )
    
    print("✅ Tâche 'Import Produits Tendance' configurée")
    
    # 3. Tâche: Mise à jour scores AI (toutes les heures)
    print("\n📊 Configuration: Mise à jour Scores AI (1h)...")
    
    PeriodicTask.objects.update_or_create(
        name='Mise à jour Scores AI',
        defaults={
            'task': 'integrations.update_product_scores',
            'interval': schedule_1h,
            'args': json.dumps([]),
            'kwargs': json.dumps({}),
            'enabled': True,
        }
    )
    
    print("✅ Tâche 'Mise à jour Scores AI' configurée")
    
    # 4. Tâche: Nettoyage produits obsolètes (toutes les 24h)
    print("\n🧹 Configuration: Nettoyage Produits (24h)...")
    
    PeriodicTask.objects.update_or_create(
        name='Nettoyage Produits Obsolètes',
        defaults={
            'task': 'integrations.cleanup_old_products',
            'interval': schedule_24h,
            'args': json.dumps([30]),  # 30 jours
            'kwargs': json.dumps({}),
            'enabled': True,
        }
    )
    
    print("✅ Tâche 'Nettoyage Produits' configurée")
    
    # 5. Résumé
    print("\n" + "=" * 60)
    print("✅ Configuration Terminée!")
    print("=" * 60)
    print("\n📋 Tâches Automatiques Configurées:")
    print("1. Import Produits Tendance → Toutes les 6 heures")
    print("2. Mise à jour Scores AI → Toutes les heures")
    print("3. Nettoyage Produits → Toutes les 24 heures")
    print("\n🎯 Catégories Surveillées:")
    print("   - Phone accessories")
    print("   - Smart watch")
    print("   - Wireless earbuds")
    print("   - LED lights")
    print("   - Home decor")
    print("   - Fitness equipment")
    print("   - Beauty products")
    print("   - Pet supplies")
    print("\n🚀 Pour Démarrer:")
    print("1. Installer Redis: choco install redis (Windows)")
    print("2. Démarrer Redis: redis-server")
    print("3. Démarrer Celery Worker:")
    print("   celery -A dropshipping_finder worker -l info")
    print("4. Démarrer Celery Beat:")
    print("   celery -A dropshipping_finder beat -l info")
    print("=" * 60)

if __name__ == '__main__':
    setup_automatic_imports()
