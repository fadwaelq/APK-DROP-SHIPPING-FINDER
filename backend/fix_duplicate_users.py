#!/usr/bin/env python
"""
Script pour corriger les utilisateurs dupliqués dans la base de données
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import UserProfile
from django.db.models import Count

def fix_duplicate_users():
    """Trouve et corrige les utilisateurs dupliqués"""
    
    print("🔍 Recherche des utilisateurs dupliqués...")
    print("=" * 60)
    
    # Trouver les emails dupliqués
    duplicates = User.objects.values('email').annotate(
        count=Count('email')
    ).filter(count__gt=1)
    
    if not duplicates:
        print("✅ Aucun utilisateur dupliqué trouvé!")
        return
    
    print(f"⚠️  Trouvé {len(duplicates)} email(s) dupliqué(s)\n")
    
    for dup in duplicates:
        email = dup['email']
        count = dup['count']
        
        print(f"📧 Email: {email} ({count} comptes)")
        
        # Récupérer tous les utilisateurs avec cet email
        users = User.objects.filter(email=email).order_by('date_joined')
        
        # Garder le premier utilisateur (le plus ancien)
        keep_user = users.first()
        delete_users = users[1:]
        
        print(f"   ✅ Garder: ID={keep_user.id}, Username={keep_user.username}, Date={keep_user.date_joined}")
        
        # Supprimer les doublons
        for user in delete_users:
            print(f"   ❌ Supprimer: ID={user.id}, Username={user.username}, Date={user.date_joined}")
            
            # Supprimer le profil associé si existe
            try:
                profile = UserProfile.objects.get(user=user)
                profile.delete()
                print(f"      → Profil supprimé")
            except UserProfile.DoesNotExist:
                pass
            
            # Supprimer l'utilisateur
            user.delete()
            print(f"      → Utilisateur supprimé")
        
        print()
    
    print("=" * 60)
    print("✅ Nettoyage terminé!")
    print("\n📊 Résumé des utilisateurs restants:")
    print("=" * 60)
    
    all_users = User.objects.all().order_by('date_joined')
    for user in all_users:
        has_profile = UserProfile.objects.filter(user=user).exists()
        profile_status = "✅ Avec profil" if has_profile else "⚠️  Sans profil"
        print(f"ID={user.id:3d} | {user.username:20s} | {user.email:30s} | {profile_status}")
    
    print("=" * 60)
    print(f"Total: {all_users.count()} utilisateur(s)")

if __name__ == '__main__':
    try:
        fix_duplicate_users()
    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
