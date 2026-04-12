import pytest
from django.urls import reverse
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model

User = get_user_model()

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def auth_user(db):
    user = User.objects.create_user(username="testuser", email="test@example.com", password="password")
    client = APIClient()
    client.force_authenticate(user=user)
    return user, client

@pytest.mark.django_db
def test_earn_coins_invalid_amount(auth_user):
    _, client = auth_user
    url = "/api/economy/user/coins/earn/" 
    response = client.post(url, {"amount": 0})
    assert response.status_code == 400
    assert response.data["error"] == "Montant invalide"

