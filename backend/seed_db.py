import os
import sys
import django
import csv
from decimal import Decimal

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from django.contrib.auth.models import User
from core.models import UserProfile, Product

def seed_database():
    """Seed database with CSV data"""
    
    print("\n" + "="*60)
    print("🔧 STARTING DATABASE SEEDING...")
    print("="*60 + "\n")
    
    # 1. Create test user
    print("👤 Creating test user...")
    user, created = User.objects.get_or_create(
        username='testuser',
        defaults={
            'email': 'test@example.com',
            'first_name': 'Test',
            'last_name': 'User',
            'is_active': True,
        }
    )
    if created:
        user.set_password('password123')
        user.save()
        print(f"   ✅ Created user: {user.email}")
    else:
        print(f"   ⚠️  User already exists: {user.email}")
    
    # Create user profile
    profile, _ = UserProfile.objects.get_or_create(user=user)
    print(f"   ✅ User profile ready\n")
    
    # 2. Category mapping
    category_mapping = {
        'Electronics': 'tech',
        'Fashion': 'fashion',
        'Home': 'home',
        'Sports': 'sport',
        'Beauty': 'beauty',
        'Toys': 'toys',
        'Health': 'health',
    }
    
    # 3. CSV files to import
    csv_files = [
        'aliexpress_mock_20260205_230735.csv',
        'aliexpress_mock_20260205_230836.csv',
        'aliexpress_mock_20260205_230842.csv',
        'aliexpress_mock_20260205_234614.csv',
    ]
    
    total_imported = 0
    total_skipped = 0
    total_errors = 0
    
    # 4. Import from CSV files
    print("📥 IMPORTING PRODUCTS FROM CSV...\n")
    
    for csv_file in csv_files:
        if not os.path.exists(csv_file):
            print(f"   ⚠️  {csv_file} not found, skipping...")
            continue
        
        print(f"   📄 Processing: {csv_file}")
        file_imported = 0
        file_skipped = 0
        
        try:
            with open(csv_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                
                for row in reader:
                    try:
                        product_id = row.get('Product ID', '').strip()
                        
                        # Skip if already exists
                        if Product.objects.filter(source_id=product_id).exists():
                            file_skipped += 1
                            total_skipped += 1
                            continue
                        
                        # Parse data
                        title = row.get('Title', 'Unknown').strip()
                        price = float(row.get('Price ($)', 0))
                        original_price = float(row.get('Original Price ($)', 0))
                        cost = original_price * 0.3  # Cost is 30% of original
                        category = row.get('Category', 'Electronics').strip()
                        rating = float(row.get('Rating (★)', 0))
                        reviews = int(row.get('Reviews', 0))
                        url = row.get('URL', '').strip()
                        image_url = row.get('Image URL', '').strip()
                        search_keyword = row.get('Search Keyword', '').strip()
                        
                        # Map category
                        mapped_category = category_mapping.get(category, 'tech')
                        
                        # Create product
                        product = Product.objects.create(
                            name=title,
                            description=f"Smart watch imported from AliExpress. Search keyword: {search_keyword}",
                            price=Decimal(str(price)),
                            cost=Decimal(str(cost)),
                            profit=Decimal(str(price - cost)),
                            category=mapped_category,
                            source='aliexpress',
                            source_url=url,
                            source_id=product_id,
                            image_url=image_url,
                            images=[image_url] if image_url else [],
                            supplier_name='AliExpress Seller',
                            supplier_rating=Decimal(str(rating)),
                            supplier_review_count=reviews,
                            trend_percentage=Decimal('25.5'),
                            is_active=True,
                            is_trending=rating >= 4.4,  # Trending if high rating
                            score=int(rating * 20),  # Simple score calculation
                        )
                        
                        file_imported += 1
                        total_imported += 1
                        
                    except Exception as e:
                        total_errors += 1
                        continue
            
            print(f"      ✅ {file_imported} imported, ⏭️  {file_skipped} skipped")
            
        except Exception as e:
            print(f"      ❌ Error reading {csv_file}: {str(e)}")
    
    # 5. Print summary
    print("\n" + "="*60)
    print("✨ DATABASE SEEDING COMPLETE!")
    print("="*60)
    print(f"\n📊 STATISTICS:")
    print(f"   ✅ Total imported: {total_imported}")
    print(f"   ⏭️  Total skipped: {total_skipped}")
    print(f"   ❌ Total errors: {total_errors}")
    print(f"   📦 Total products in DB: {Product.objects.count()}")
    print(f"   🔥 Trending products: {Product.objects.filter(is_trending=True).count()}")
    print(f"\n👤 TEST USER:")
    print(f"   Username: testuser")
    print(f"   Email: test@example.com")
    print(f"   Password: password123")
    print("\n" + "="*60)

if __name__ == '__main__':
    seed_database()
