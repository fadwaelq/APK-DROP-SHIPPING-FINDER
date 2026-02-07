# 🚀 Professional AliExpress Scraper - Quick Start Guide

## Installation

```bash
cd backend
pip install beautifulsoup4 lxml requests urllib3
```

## Usage Examples

### 1. Scrape by keyword (simplest)
```bash
python scrape_aliexpress_pro.py --query "smartwatch" --pages 2
```

### 2. Scrape with specific limit
```bash
python scrape_aliexpress_pro.py --query "wireless earbuds" --pages 3 --limit 50
```

### 3. Scrape with more pages
```bash
python scrape_aliexpress_pro.py --query "phone case" --pages 5 --limit 100
```

### 4. Scrape with Tor (slower but anonymous)
```bash
python scrape_aliexpress_pro.py --query "smartwatch" --pages 2 --tor
```

### 5. Scrape with custom timeout
```bash
python scrape_aliexpress_pro.py --query "headphones" --pages 2 --timeout 20 --retries 5
```

## Features

✅ **Anti-Detection**: Realistic browser headers, random delays
✅ **Error Handling**: Automatic retries with exponential backoff
✅ **Logging**: Detailed logs saved to `scraping.log`
✅ **Database**: Automatically saves to Django database
✅ **Deduplication**: Avoids duplicate products
✅ **Progress Tracking**: Real-time progress in console
✅ **Statistics**: Detailed report at the end
✅ **Production Ready**: Professional error handling

## Expected Output

```
======================================================================
🚀 PROFESSIONAL ALIEXPRESS SCRAPER - v1.0
======================================================================

🔍 Starting scrape for keyword: 'smartwatch' (2 pages, limit: 100)
📄 Processing page 1/2...
   Found 30 items on page 1
   [5/30] ✅ Smart Watch Fitness Tracker...
   [10/30] ✅ AMOLED Display Smartwatch...
   [15/30] ✅ Sports Smart Watch...
   [20/30] ✅ Water Resistant Smartwatch...
   [25/30] ✅ GPS Smartwatch...
   [30/30] ✅ HD Display Smart Watch...
📄 Processing page 2/2...
   Found 25 items on page 2
   [35/55] ✅ Bluetooth Smartwatch...
   [40/55] ✅ Heart Rate Monitor Watch...
   [45/55] ✅ Sleep Tracker Smartwatch...
   [50/55] ✅ Music Control Smartwatch...
   [55/55] ✅ Waterproof Smart Watch...
✅ Scraping complete: Found 55 products

💾 Saving 55 products to database...
   [5/55] ✅ Smart Watch Fitness Tracker...
   [10/55] ✅ AMOLED Display Smartwatch...
   [15/55] ✅ Sports Smart Watch...
   [20/55] ✅ Water Resistant Smartwatch...
   [25/55] ✅ GPS Smartwatch...
   [30/55] ✅ HD Display Smart Watch...
   [35/55] ✅ Bluetooth Smartwatch...
   [40/55] ✅ Heart Rate Monitor Watch...
   [45/55] ✅ Sleep Tracker Smartwatch...
   [50/55] ✅ Music Control Smartwatch...
   [55/55] ✅ Waterproof Smart Watch...

======================================================================
📊 SCRAPING STATISTICS
======================================================================
✅ Created:     55 products
🔄 Updated:     0 products
❌ Errors:      0
📈 Total Found: 55 products
⏱️  Duration:    0:02:45.321456
🔗 Database:    55 total products
======================================================================
```

## Checking Results

### View in Django Admin
```bash
python manage.py runserver
# Go to http://localhost:8000/admin
# Check Products section
```

### View in Python Shell
```bash
python manage.py shell
>>> from core.models import Product
>>> Product.objects.count()  # Total products
>>> Product.objects.filter(category='tech').count()  # By category
>>> Product.objects.order_by('-supplier_review_count')[:5]  # Top 5 by sales
```

## Troubleshooting

### SSL Certificate Error
Add this to skip SSL verification (not recommended for production):
```python
# Line already handled in scraper with verify=False
```

### Connection Timeout
Increase timeout:
```bash
python scrape_aliexpress_pro.py --query "smartwatch" --timeout 30
```

### Getting Blocked
Use Tor proxy:
```bash
# First install Tor
pip install stem PySocks

# Then use Tor in scraper
python scrape_aliexpress_pro.py --query "smartwatch" --tor
```

## Performance Tips

1. **Start with 1-2 pages** to test
2. **Use --limit 20** for quick tests
3. **Increase pages gradually** to avoid detection
4. **Run at different times** to avoid patterns
5. **Use different keywords** to distribute load

## Next Steps

1. ✅ Run the scraper: `python scrape_aliexpress_pro.py --query "smartwatch" --pages 2`
2. ✅ Check database: Visit http://localhost:8000/admin
3. ✅ View products: Visit http://localhost:3000 (frontend)
4. ✅ Schedule daily: Set up cron job for automated scraping

## Schedule Daily Scraping (Linux/Mac)

```bash
# Add to crontab
crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "smartwatch" --pages 2

# For multiple keywords
0 2 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "smartwatch" --pages 2
0 3 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "wireless earbuds" --pages 2
0 4 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "phone case" --pages 2
```

## Support

For issues, check:
- `scraping.log` - Detailed error logs
- Database migrations - Run `python manage.py migrate`
- Installed packages - Run `pip install -r requirements.txt`
