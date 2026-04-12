import pytest
from subscriptions.models import SubscriptionPlan, UserSubscription
from django.contrib.auth import get_user_model

User = get_user_model()

@pytest.mark.django_db
def test_user_subscription_creation():
    user = User.objects.create_user(username="subuser", email="sub@example.com", password="password")
    from django.utils import timezone
    from datetime import timedelta
    end_date = timezone.now() + timedelta(days=30)
    sub, _ = UserSubscription.objects.get_or_create(user=user, defaults={"end_date": end_date})
    assert sub.user == user
    assert sub.is_active == False
