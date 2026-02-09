# 🚀 Professional AliExpress Scraper - Complete Setup

## 📦 What You Get

I've created **4 professional scraping scripts**:

1. **scrape_aliexpress_pro.py** - Professional production scraper
2. **quick_import.py** - Fast test with mock products
3. **run_scraper.bat** - Windows batch launcher
4. **run_scraper.ps1** - Windows PowerShell launcher

---

## ⚡ Quick Start (30 seconds)

### Option A: Import Mock Products (Instant ✅)
```bash
cd backend
python quick_import.py
```

**Result**: 10 products created in ~2 seconds

### Option B: Professional Scraper (Real Data 🌐)
```bash
cd backend
python scrape_aliexpress_pro.py --query "smartwatch" --pages 2
```

**Result**: 20-50 real products from AliExpress in ~3 minutes

### Option C: Windows GUI Menu (Easy 🖱️)
```bash
# Double-click this file:
run_scraper.ps1

# Or in PowerShell:
.\run_scraper.ps1
```

---

## 📋 Installation

### Step 1: Install Dependencies
```bash
cd backend
pip install beautifulsoup4 lxml requests urllib3
```

**That's it!** ✅ No complex setup needed.

### Step 2 (Optional): For Tor Proxy
```bash
pip install stem PySocks
```

---

## 🎯 Usage Examples

### Scrape by Keyword
```bash
# Simple (defaults: 1 page, 100 limit)
python scrape_aliexpress_pro.py --query "smartwatch"

# With pages
python scrape_aliexpress_pro.py --query "smartwatch" --pages 3

# With limit
python scrape_aliexpress_pro.py --query "smartwatch" --pages 2 --limit 50

# Everything
python scrape_aliexpress_pro.py --query "smartwatch" --pages 5 --limit 100
```

### Advanced Options
```bash
# With Tor (slower but anonymous)
python scrape_aliexpress_pro.py --query "smartwatch" --tor

# Custom timeout
python scrape_aliexpress_pro.py --query "smartwatch" --timeout 30

# More retries
python scrape_aliexpress_pro.py --query "smartwatch" --retries 5

# All options
python scrape_aliexpress_pro.py --query "smartwatch" --pages 3 --limit 50 --tor --timeout 20 --retries 3
```

---

## 🔍 Popular Search Keywords

```bash
python scrape_aliexpress_pro.py --query "smartwatch" --pages 2
python scrape_aliexpress_pro.py --query "wireless earbuds" --pages 2
python scrape_aliexpress_pro.py --query "phone case" --pages 2
python scrape_aliexpress_pro.py --query "LED light" --pages 2
python scrape_aliexpress_pro.py --query "power bank" --pages 2
python scrape_aliexpress_pro.py --query "yoga mat" --pages 2
python scrape_aliexpress_pro.py --query "phone holder" --pages 2
python scrape_aliexpress_pro.py --query "USB cable" --pages 2
```

---

## 📊 View Results

### In Django Admin
```bash
python manage.py runserver
# Visit: http://localhost:8000/admin
# Username: admin
# Check Products section
```

### In Python Shell
```bash
python manage.py shell
>>> from core.models import Product
>>> Product.objects.count()  # Total
>>> Product.objects.filter(category='tech')  # By category
>>> Product.objects.order_by('-supplier_review_count')[:5]  # Top 5
>>> Product.objects.filter(is_trending=True).count()  # Trending
```

### In Frontend
```bash
npm run dev  # If using React/Vue frontend
# Visit: http://localhost:3000
```

---

## 📈 Script Comparison

| Feature | quick_import.py | scrape_aliexpress_pro.py |
|---------|-----------------|--------------------------|
| Speed | ⚡⚡⚡ Instant | 🐢 30 sec - 5 min |
| Data | 📦 Mock (10 products) | 🌐 Real (20-100 products) |
| Database | ✅ Yes | ✅ Yes |
| Setup | 0 minutes | 1 minute |
| Real Scraping | ❌ No | ✅ Yes |
| Best For | Testing, Demo | Production |

---

## 🔧 Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'bs4'"
**Solution:**
```bash
pip install beautifulsoup4
```

### Issue: "ConnectionError"
**Solution:**
```bash
# Increase timeout
python scrape_aliexpress_pro.py --query "smartwatch" --timeout 30
```

### Issue: "Getting blocked by AliExpress"
**Solution 1**: Use Tor
```bash
python scrape_aliexpress_pro.py --query "smartwatch" --tor
```

**Solution 2**: Scrape fewer pages/slower
```bash
python scrape_aliexpress_pro.py --query "smartwatch" --pages 1
```

### Issue: "No products found"
**Solution:**
- Check internet connection
- Try different keyword
- Increase --pages
- Check scraping.log for errors: `tail scraping.log`

### Issue: "Database error"
**Solution:**
```bash
# Migrate database
python manage.py migrate

# Check Product model
python manage.py shell
>>> from core.models import Product
>>> Product._meta.fields
```

---

## 📝 Logs & Debugging

### View Logs
```bash
# Last 20 lines
tail -n 20 scraping.log

# Or in PowerShell
Get-Content scraping.log -Tail 20
```

### Check All Products
```bash
python manage.py shell
>>> from core.models import Product
>>> for p in Product.objects.all()[:5]:
...     print(f"{p.name} - ${p.price}")
```

---

## 🚀 Schedule Daily Scraping

### Linux/Mac (Crontab)
```bash
# Edit crontab
crontab -e

# Add lines (runs at 2 AM daily):
0 2 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "smartwatch" --pages 2

# For multiple keywords (different times):
0 2 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "smartwatch" --pages 2
0 3 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "wireless earbuds" --pages 2
0 4 * * * cd /path/to/backend && python scrape_aliexpress_pro.py --query "phone case" --pages 2
```

### Windows (Task Scheduler)
1. Open Task Scheduler
2. Create Basic Task
3. Set Trigger: Daily at 2:00 AM
4. Set Action: 
   - Program: `C:\Python312\python.exe`
   - Arguments: `scrape_aliexpress_pro.py --query "smartwatch" --pages 2`
   - Start in: `C:\path\to\backend`

### Using Python (Cross-platform)
```bash
pip install schedule

# Create schedule_scraper.py
import schedule
import time
import subprocess

schedule.every().day.at("02:00").do(
    subprocess.run,
    ["python", "scrape_aliexpress_pro.py", "--query", "smartwatch", "--pages", "2"]
)

while True:
    schedule.run_pending()
    time.sleep(60)
```

---

## ✨ Features

✅ **Anti-Detection**
- Realistic browser headers
- Random delays (2-5 seconds)
- Proper User-Agent
- Referer handling

✅ **Robust Error Handling**
- Automatic retries (3 by default)
- Exponential backoff
- Connection timeouts
- Detailed error logging

✅ **Data Quality**
- Deduplication (no duplicates)
- Price parsing
- Image URL validation
- Category auto-detection

✅ **Database Integration**
- Auto-creates/updates products
- Calculates profit margins
- Tracks trending status
- Timestamps scraping

✅ **Professional Logging**
- File-based logs (scraping.log)
- Console output
- Timestamped entries
- Progress tracking

---

## 📞 Support

### Check Logs
```bash
cat scraping.log | grep ERROR
```

### Test Connection
```bash
python -c "import requests; print(requests.get('https://www.aliexpress.com').status_code)"
```

### Test Database
```bash
python manage.py shell
>>> from core.models import Product
>>> Product.objects.count()
```

---

## 🎯 Next Steps

1. ✅ Run quick_import.py for instant test products
2. ✅ View results in Django admin
3. ✅ Try professional scraper with 1 keyword
4. ✅ Expand to multiple keywords
5. ✅ Set up daily scheduling
6. ✅ Monitor logs for optimization

---

## 📚 Files Created

| File | Purpose | Type |
|------|---------|------|
| scrape_aliexpress_pro.py | Main professional scraper | Python Script |
| quick_import.py | Fast test import | Python Script |
| run_scraper.bat | Windows batch launcher | Batch File |
| run_scraper.ps1 | Windows PowerShell launcher | PowerShell Script |
| SCRAPER_PRO_GUIDE.md | Detailed guide | Documentation |
| scraping.log | Scraping logs | Log File |

---

## 💡 Tips for Best Results

1. **Start small**: Test with 1 page, 20 products
2. **Vary keywords**: Different searches = better data
3. **Respect AliExpress**: Don't scrape 24/7
4. **Use delays**: Built-in delays help avoid blocks
5. **Monitor logs**: Check scraping.log for issues
6. **Schedule wisely**: Scrape during off-peak hours (midnight-6 AM)

---

**Happy Scraping! 🚀**
