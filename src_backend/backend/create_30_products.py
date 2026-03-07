import os
import sys
import django
from decimal import Decimal

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from core.models import Product

def create_30_products():
    """Create 30 diverse sample products"""
    
    print("\n" + "="*60)
    print("🎯 CREATING 30 PRODUCTS...")
    print("="*60 + "\n")
    
    products_data = [
        # Electronics - Tech (10 products)
        {
            'name': 'Wireless USB-C Headphones',
            'description': 'Premium wireless headphones with active noise cancellation and 30-hour battery life',
            'price': 89.99,
            'cost': 25.00,
            'category': 'tech',
            'supplier_rating': 4.8,
            'supplier_review_count': 1250,
            'is_trending': True,
        },
        {
            'name': 'Fast Charging 65W Power Adapter',
            'description': 'Universal fast charger compatible with all devices, compact design',
            'price': 29.99,
            'cost': 8.50,
            'category': 'tech',
            'supplier_rating': 4.6,
            'supplier_review_count': 2890,
            'is_trending': True,
        },
        {
            'name': 'Portable SSD 1TB External Drive',
            'description': '1TB portable SSD with USB 3.1, extremely durable and fast',
            'price': 119.99,
            'cost': 45.00,
            'category': 'tech',
            'supplier_rating': 4.7,
            'supplier_review_count': 1560,
            'is_trending': True,
        },
        {
            'name': '4K USB Camera for Video Conference',
            'description': 'Professional 4K webcam with auto-focus and noise reduction',
            'price': 74.99,
            'cost': 20.00,
            'category': 'tech',
            'supplier_rating': 4.5,
            'supplier_review_count': 890,
            'is_trending': False,
        },
        {
            'name': 'Mechanical Gaming Keyboard RGB',
            'description': 'Professional mechanical keyboard with RGB lights and macro keys',
            'price': 99.99,
            'cost': 28.00,
            'category': 'tech',
            'supplier_rating': 4.9,
            'supplier_review_count': 2100,
            'is_trending': True,
        },
        {
            'name': 'Wireless Mouse 2.4GHz Precision',
            'description': 'Ergonomic wireless mouse with precision tracking, 18-month battery',
            'price': 19.99,
            'cost': 5.00,
            'category': 'tech',
            'supplier_rating': 4.4,
            'supplier_review_count': 3400,
            'is_trending': False,
        },
        {
            'name': 'USB Hub 7-Port 3.0 with Power',
            'description': 'High-speed USB hub with individual switches and power adapter',
            'price': 34.99,
            'cost': 9.50,
            'category': 'tech',
            'supplier_rating': 4.6,
            'supplier_review_count': 1200,
            'is_trending': False,
        },
        {
            'name': 'Laptop Cooling Pad with Fans',
            'description': 'Electric cooling pad with dual fans to keep laptop cool',
            'price': 24.99,
            'cost': 7.00,
            'category': 'tech',
            'supplier_rating': 4.3,
            'supplier_review_count': 950,
            'is_trending': False,
        },
        {
            'name': 'Phone Stand Adjustable Aluminum',
            'description': 'Heavy-duty aluminum phone stand for desk, adjustable height',
            'price': 15.99,
            'cost': 3.50,
            'category': 'tech',
            'supplier_rating': 4.7,
            'supplier_review_count': 2560,
            'is_trending': False,
        },
        {
            'name': 'Tablet Stylus Pen Precision 4096',
            'description': 'Professional stylus pen with 4096 pressure levels',
            'price': 44.99,
            'cost': 12.00,
            'category': 'tech',
            'supplier_rating': 4.5,
            'supplier_review_count': 680,
            'is_trending': False,
        },

        # Home & Garden (8 products)
        {
            'name': 'LED Smart Bulb WiFi RGB',
            'description': 'Smart LED bulb with WiFi control, 16 million colors, voice control',
            'price': 14.99,
            'cost': 3.50,
            'category': 'home',
            'supplier_rating': 4.6,
            'supplier_review_count': 4200,
            'is_trending': True,
        },
        {
            'name': 'Smart Door Lock WiFi Keyless',
            'description': 'Smart door lock with fingerprint and app control',
            'price': 89.99,
            'cost': 28.00,
            'category': 'home',
            'supplier_rating': 4.4,
            'supplier_review_count': 1340,
            'is_trending': True,
        },
        {
            'name': 'Robot Vacuum Cleaner Smart',
            'description': 'Autonomous vacuum with smart mapping and app control',
            'price': 199.99,
            'cost': 65.00,
            'category': 'home',
            'supplier_rating': 4.7,
            'supplier_review_count': 2800,
            'is_trending': True,
        },
        {
            'name': 'Air Humidifier Ultrasonic 2L',
            'description': 'Quiet ultrasonic humidifier with aromatherapy function',
            'price': 29.99,
            'cost': 8.00,
            'category': 'home',
            'supplier_rating': 4.5,
            'supplier_review_count': 1560,
            'is_trending': False,
        },
        {
            'name': 'Smart Thermostat WiFi Control',
            'description': 'WiFi thermostat with learning technology and remote control',
            'price': 79.99,
            'cost': 22.00,
            'category': 'home',
            'supplier_rating': 4.8,
            'supplier_review_count': 3100,
            'is_trending': True,
        },
        {
            'name': 'Electric Kettle Temperature Control',
            'description': 'Smart electric kettle with temperature control and timer',
            'price': 34.99,
            'cost': 9.00,
            'category': 'home',
            'supplier_rating': 4.6,
            'supplier_review_count': 2200,
            'is_trending': False,
        },
        {
            'name': 'Wireless Doorbell Smart Camera',
            'description': 'WiFi video doorbell with night vision and motion detection',
            'price': 59.99,
            'cost': 16.00,
            'category': 'home',
            'supplier_rating': 4.7,
            'supplier_review_count': 1890,
            'is_trending': True,
        },
        {
            'name': 'Bedside Lamp with USB Charging',
            'description': 'Modern LED bedside lamp with integrated USB charging port',
            'price': 24.99,
            'cost': 6.00,
            'category': 'home',
            'supplier_rating': 4.4,
            'supplier_review_count': 890,
            'is_trending': False,
        },

        # Fashion & Accessories (7 products)
        {
            'name': 'Polarized Sunglasses UV Protection',
            'description': 'Premium polarized sunglasses with UV400 protection',
            'price': 39.99,
            'cost': 10.00,
            'category': 'fashion',
            'supplier_rating': 4.5,
            'supplier_review_count': 2100,
            'is_trending': False,
        },
        {
            'name': 'Canvas Backpack Travel School',
            'description': 'Durable canvas backpack with laptop compartment',
            'price': 44.99,
            'cost': 12.00,
            'category': 'fashion',
            'supplier_rating': 4.6,
            'supplier_review_count': 3200,
            'is_trending': False,
        },
        {
            'name': 'Leather Wallet RFID Protection',
            'description': 'Slim leather wallet with RFID blocking technology',
            'price': 24.99,
            'cost': 6.50,
            'category': 'fashion',
            'supplier_rating': 4.7,
            'supplier_review_count': 1450,
            'is_trending': False,
        },
        {
            'name': 'Stainless Steel Watch Unisex',
            'description': 'Classic stainless steel watch with water resistance',
            'price': 49.99,
            'cost': 14.00,
            'category': 'fashion',
            'supplier_rating': 4.8,
            'supplier_review_count': 2800,
            'is_trending': True,
        },
        {
            'name': 'Baseball Cap Adjustable Cotton',
            'description': 'Comfortable adjustable cotton baseball cap',
            'price': 12.99,
            'cost': 2.50,
            'category': 'fashion',
            'supplier_rating': 4.3,
            'supplier_review_count': 890,
            'is_trending': False,
        },
        {
            'name': 'Phone Case Leather Slim Fit',
            'description': 'Slim leather phone case with precise cutouts',
            'price': 19.99,
            'cost': 4.00,
            'category': 'fashion',
            'supplier_rating': 4.6,
            'supplier_review_count': 4100,
            'is_trending': False,
        },
        {
            'name': 'Bluetooth Speaker Portable Mini',
            'description': 'Portable mini Bluetooth speaker with deep bass',
            'price': 34.99,
            'cost': 9.00,
            'category': 'fashion',
            'supplier_rating': 4.5,
            'supplier_review_count': 2340,
            'is_trending': False,
        },

        # Sports & Fitness (5 products)
        {
            'name': 'Yoga Mat Extra Thick Non-Slip',
            'description': 'Premium thick yoga mat with non-slip surface',
            'price': 29.99,
            'cost': 8.00,
            'category': 'sport',
            'supplier_rating': 4.7,
            'supplier_review_count': 2100,
            'is_trending': False,
        },
        {
            'name': 'Resistance Bands Set 5 Levels',
            'description': '5-pack resistance bands for full body workout',
            'price': 19.99,
            'cost': 4.50,
            'category': 'sport',
            'supplier_rating': 4.6,
            'supplier_review_count': 3400,
            'is_trending': True,
        },
        {
            'name': 'Dumbbells Adjustable Weight Set',
            'description': 'Adjustable dumbbell set from 2.5kg to 10kg',
            'price': 89.99,
            'cost': 28.00,
            'category': 'sport',
            'supplier_rating': 4.8,
            'supplier_review_count': 1890,
            'is_trending': True,
        },
        {
            'name': 'Jump Rope Speed Training Bearing',
            'description': 'Professional jump rope with bearing handles',
            'price': 14.99,
            'cost': 3.00,
            'category': 'sport',
            'supplier_rating': 4.5,
            'supplier_review_count': 1200,
            'is_trending': False,
        },
        {
            'name': 'Foam Roller Muscle Recovery',
            'description': 'High-density foam roller for muscle massage',
            'price': 24.99,
            'cost': 6.50,
            'category': 'sport',
            'supplier_rating': 4.6,
            'supplier_review_count': 2300,
            'is_trending': False,
        },
    ]
    
    created_count = 0
    skipped_count = 0
    
    for data in products_data:
        try:
            # Check if product already exists
            if Product.objects.filter(name=data['name']).exists():
                skipped_count += 1
                print(f"   ⏭️  Skipped: {data['name']} (already exists)")
                continue
            
            # Create product
            product = Product.objects.create(
                name=data['name'],
                description=data['description'],
                price=Decimal(str(data['price'])),
                cost=Decimal(str(data['cost'])),
                profit=Decimal(str(data['price'] - data['cost'])),
                category=data['category'],
                source='aliexpress',
                source_url=f"https://www.aliexpress.com/item/{created_count}/",
                source_id=f"test_{created_count}",
                image_url=f"https://ae01.alicdn.com/kf/test_{created_count}.jpg",
                supplier_name='Premium Supplier',
                supplier_rating=Decimal(str(data['supplier_rating'])),
                supplier_review_count=data['supplier_review_count'],
                trend_percentage=Decimal('22.5'),
                is_active=True,
                is_trending=data['is_trending'],
                score=int(data['supplier_rating'] * 20),
            )
            
            created_count += 1
            print(f"   ✅ Created: {product.name} (${product.price})")
            
        except Exception as e:
            print(f"   ❌ Error: {data['name']} - {str(e)}")
            continue
    
    # Print summary
    print("\n" + "="*60)
    print("✨ PRODUCT CREATION COMPLETE!")
    print("="*60)
    print(f"\n📊 STATISTICS:")
    print(f"   ✅ Created: {created_count}")
    print(f"   ⏭️  Skipped: {skipped_count}")
    print(f"   📦 Total products in DB: {Product.objects.count()}")
    print(f"   🔥 Trending products: {Product.objects.filter(is_trending=True).count()}")
    print(f"   💼 By category:")
    print(f"      - Tech: {Product.objects.filter(category='tech').count()}")
    print(f"      - Home: {Product.objects.filter(category='home').count()}")
    print(f"      - Fashion: {Product.objects.filter(category='fashion').count()}")
    print(f"      - Sport: {Product.objects.filter(category='sport').count()}")
    print("="*60 + "\n")

if __name__ == '__main__':
    create_30_products()