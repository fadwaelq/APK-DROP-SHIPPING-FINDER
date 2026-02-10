import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from core.models import Product

# Valid product images from Unsplash
IMAGE_URLS = {
    'Wireless USB-C Headphones': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop',
    'Fast Charging 65W Power Adapter': 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=500&h=500&fit=crop',
    'Portable SSD 1TB External Drive': 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=500&h=500&fit=crop',
    '4K USB Camera for Video Conference': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500&h=500&fit=crop',
    'Mechanical Gaming Keyboard RGB': 'https://images.unsplash.com/photo-1587829191301-7ce2f3dbe3cb?w=500&h=500&fit=crop',
    'Wireless Mouse 2.4GHz Precision': 'https://images.unsplash.com/photo-1527814050087-3793815479db?w=500&h=500&fit=crop',
    'USB Hub 7-Port 3.0 with Power': 'https://images.unsplash.com/photo-1625948515291-69613efd103f?w=500&h=500&fit=crop',
    'Laptop Cooling Pad with Fans': 'https://images.unsplash.com/photo-1588872657840-e78f119e0c71?w=500&h=500&fit=crop',
    'Phone Stand Adjustable Aluminum': 'https://images.unsplash.com/photo-1605559424843-9e4c3effc877?w=500&h=500&fit=crop',
    'Tablet Stylus Pen Precision 4096': 'https://images.unsplash.com/photo-1552820728-8ac41f1ce891?w=500&h=500&fit=crop',
    
    # Home
    'LED Smart Bulb WiFi RGB': 'https://images.unsplash.com/photo-1565636192335-14f8d8d5b95f?w=500&h=500&fit=crop',
    'Smart Door Lock WiFi Keyless': 'https://images.unsplash.com/photo-1557522954816-8cdf29e7b9f8?w=500&h=500&fit=crop',
    'Robot Vacuum Cleaner Smart': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop',
    'Air Humidifier Ultrasonic 2L': 'https://images.unsplash.com/photo-1589293476549-5b0267db2c09?w=500&h=500&fit=crop',
    'Smart Thermostat WiFi Control': 'https://images.unsplash.com/photo-1545259741-2ea3ebdc61fa?w=500&h=500&fit=crop',
    'Electric Kettle Temperature Control': 'https://images.unsplash.com/photo-1591290621749-b4b9ebf1c620?w=500&h=500&fit=crop',
    'Wireless Doorbell Smart Camera': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop',
    'Bedside Lamp with USB Charging': 'https://images.unsplash.com/photo-1565636192335-14f8d8d5b95f?w=500&h=500&fit=crop',
    
    # Fashion
    'Polarized Sunglasses UV Protection': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500&h=500&fit=crop',
    'Canvas Backpack Travel School': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&h=500&fit=crop',
    'Leather Wallet RFID Protection': 'https://images.unsplash.com/photo-1504224155058-0a13dfeadb3e?w=500&h=500&fit=crop',
    'Stainless Steel Watch Unisex': 'https://images.unsplash.com/photo-1523170335684-f042f1995e39?w=500&h=500&fit=crop',
    'Baseball Cap Adjustable Cotton': 'https://images.unsplash.com/photo-1552820728-8ac41f1ce891?w=500&h=500&fit=crop',
    'Phone Case Leather Slim Fit': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500&h=500&fit=crop',
    'Bluetooth Speaker Portable Mini': 'https://images.unsplash.com/photo-1589003077984-894e133814c9?w=500&h=500&fit=crop',
    
    # Sport
    'Yoga Mat Extra Thick Non-Slip': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500&h=500&fit=crop',
    'Resistance Bands Set 5 Levels': 'https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=500&h=500&fit=crop',
    'Dumbbells Adjustable Weight Set': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&h=500&fit=crop',
    'Jump Rope Speed Training Bearing': 'https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=500&h=500&fit=crop',
    'Foam Roller Muscle Recovery': 'https://images.unsplash.com/photo-1570829460005-c840387bb1ca?w=500&h=500&fit=crop',
}

def update_product_images():
    """Update all products with valid Unsplash image URLs"""
    
    print("\n" + "="*60)
    print("🖼️  UPDATING PRODUCT IMAGES...")
    print("="*60 + "\n")
    
    updated_count = 0
    not_found_count = 0
    
    for product in Product.objects.all():
        # Find image mapping
        image_url = None
        for keyword, url in IMAGE_URLS.items():
            if keyword.lower() in product.name.lower() or product.name.lower() in keyword.lower():
                image_url = url
                break
        
        if image_url:
            product.image_url = image_url
            product.save()
            updated_count += 1
            print(f"   ✅ Updated: {product.name}")
        else:
            not_found_count += 1
            print(f"   ⚠️  No image mapping: {product.name}")
    
    # Print summary
    print("\n" + "="*60)
    print("✨ IMAGE UPDATE COMPLETE!")
    print("="*60)
    print(f"\n📊 STATISTICS:")
    print(f"   ✅ Updated: {updated_count}")
    print(f"   ⚠️  Not found: {not_found_count}")
    print(f"   📦 Total products: {Product.objects.count()}")
    print("="*60 + "\n")

if __name__ == '__main__':
    update_product_images()
