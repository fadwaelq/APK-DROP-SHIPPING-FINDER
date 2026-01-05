#!/usr/bin/env python
"""Script to create a test user for the Dropshipping Finder app"""

import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import UserProfile

def create_test_user():
    """Create a test user with profile"""
    
    # Check if user already exists
    if User.objects.filter(username='test').exists():
        print("❌ User 'test' already exists!")
        user = User.objects.get(username='test')
        print(f"✅ Existing user: {user.username} / {user.email}")
        return user
    
    # Create user
    user = User.objects.create_user(
        username='test',
        email='test@example.com',
        password='test123456',
        first_name='Test',
        last_name='User'
    )
    
    # Create profile
    profile, created = UserProfile.objects.get_or_create(user=user)
    
    print("=" * 50)
    print("✅ Test user created successfully!")
    print("=" * 50)
    print(f"Username: {user.username}")
    print(f"Email: {user.email}")
    print(f"Password: test123456")
    print(f"Profile created: {created}")
    print("=" * 50)
    print("\nYou can now login with:")
    print("  Email: test@example.com")
    print("  Password: test123456")
    print("=" * 50)
    
    return user

if __name__ == '__main__':
    create_test_user()
