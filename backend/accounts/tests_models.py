import pytest
from django.contrib.auth import get_user_model

User = get_user_model()

@pytest.mark.django_db
def test_generate_otp():
    user = User.objects.create_user(username="testuser", email="test@example.com", password="password")
    otp = user.generate_otp()
    assert len(otp) == 6
    assert otp.isdigit()
    assert user.otp_code == otp
