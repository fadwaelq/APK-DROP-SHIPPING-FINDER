#!/usr/bin/env python
"""Script to reset admin password"""

import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User

def reset_admin_password():
    """Reset admin password to a known value"""
    
    try:
        # Get admin user
        admin = User.objects.get(username='admin')
        
        # Set new password
        new_password = 'admin123456'
        admin.set_password(new_password)
        admin.save()
        
        print("=" * 60)
        print("✅ Mot de passe admin réinitialisé avec succès!")
        print("=" * 60)
        print(f"Username: admin")
        print(f"Email: {admin.email}")
        print(f"Nouveau mot de passe: {new_password}")
        print("=" * 60)
        print("\nVous pouvez maintenant vous connecter à:")
        print("👉 http://localhost:8000/admin/")
        print("=" * 60)
        
    except User.DoesNotExist:
        print("❌ Utilisateur 'admin' n'existe pas!")
        print("Créez-le avec: python manage.py createsuperuser")

if __name__ == '__main__':
    reset_admin_password()
