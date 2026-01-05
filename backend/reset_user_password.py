#!/usr/bin/env python
"""
Script pour réinitialiser le mot de passe d'un utilisateur
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User

def reset_password():
    """Réinitialise le mot de passe de l'utilisateur"""
    
    email = "erradilatifa6@gmail.com"
    new_password = "latifa123"
    
    print("🔐 Réinitialisation du mot de passe")
    print("=" * 60)
    
    try:
        user = User.objects.get(email=email)
        user.set_password(new_password)
        user.save()
        
        print(f"✅ Mot de passe réinitialisé avec succès!")
        print()
        print("📧 Informations de connexion:")
        print(f"   Email:    {email}")
        print(f"   Username: {user.username}")
        print(f"   Password: {new_password}")
        print()
        print("=" * 60)
        print("🚀 Vous pouvez maintenant vous connecter!")
        
    except User.DoesNotExist:
        print(f"❌ Aucun utilisateur trouvé avec l'email: {email}")
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == '__main__':
    reset_password()
