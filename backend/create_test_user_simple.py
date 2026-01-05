#!/usr/bin/env python
"""Create a simple test user"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import UserProfile

# Delete existing test user
User.objects.filter(username='testuser').delete()
User.objects.filter(email='test@test.com').delete()

# Create new test user
user = User.objects.create_user(
    username='testuser',
    email='test@test.com',
    password='test123456',
    first_name='Test',
    last_name='User'
)

# Create profile
profile, created = UserProfile.objects.get_or_create(user=user)
profile.subscription_plan = 'free'
profile.profitability_score = 87
profile.save()

print("=" * 60)
print("✅ Test user created successfully!")
print("=" * 60)
print(f"Username: testuser")
print(f"Email: test@test.com")
print(f"Password: test123456")
print("=" * 60)
print("\n🔐 You can now login with these credentials!")
print("👉 Frontend: http://localhost:3000")
print("👉 Backend: http://localhost:8000/api/auth/login/")
print("=" * 60)
