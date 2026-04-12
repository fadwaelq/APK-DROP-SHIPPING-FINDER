import pytest
from products.models import Product, AdCampaign

@pytest.mark.django_db
def test_product_creation():
    product = Product.objects.create(
        title="Test Product",
        price=100.0,
        aliexpress_url="https://aliexpress.com/item/1.html"
    )
    assert product.title == "Test Product"
    assert str(product) == "Test Product"

@pytest.mark.django_db
def test_ad_campaign_creation():
    ad = AdCampaign.objects.create(
        title="Test Ad",
        video_url="https://video.com/1",
        platform="tiktok"
    )
    assert ad.platform == "tiktok"
    assert "Test Ad" in str(ad)
