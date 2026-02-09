# 🔍 DISCOVERY SCRAPER - QUICK START GUIDE

## What is Discovery Scraping?

**Automatic product discovery** - No manual URLs needed!

The system automatically:
- Searches trending keywords (smartwatch, power bank, wireless earbuds, etc.)
- Discovers products from AliExpress trending pages
- Finds high-potential products based on ratings, reviews, and price
- Returns URLs ready to scrape and save to database

---

## 4 Ways to Test

### **METHOD 1: EASIEST - Sync Wrapper Test**

```bash
cd c:\Users\YassIne\Desktop\Stage\APK-DROPSHIPPING-FINDER\backend
python test_discovery_scraper.py sync
```

✅ **Use this first!** Simple, no authentication needed.

---

### **METHOD 2: Async Test**

```bash
python test_discovery_scraper.py async
```

Tests the async implementation directly.

---

### **METHOD 3: API Test**

Requires Django running and a JWT token:

```bash
# Start Django
python manage.py runserver

# In another terminal, get a token first:
python -c "
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User

user = User.objects.first()  # Or create one
refresh = RefreshToken.for_user(user)
print(f'Token: {refresh.access_token}')
"

# Then test API
python test_discovery_scraper.py api --token YOUR_TOKEN_HERE
```

Tests via REST API endpoint.

---

### **METHOD 4: PowerShell Curl**

```bash
python test_discovery_scraper.py curl
```

Prints PowerShell curl command you can copy & paste.

---

## Full Workflow Example

**Discover → Scrape → Export to Excel**

```powershell
# 1. Activate venv
& "C:/Users/YassIne/Desktop/Stage/APK-DROPSHIPPING-FINDER/backend/venv/Scripts/Activate.ps1"

# 2. Run discovery
python test_discovery_scraper.py sync

# 3. Copy the URLs from output

# 4. Use scrape-batch to scrape them
# POST /api/products/scrape-batch/
# Body: {"urls": ["https://...", "https://..."]}

# 5. Export to Excel
# POST /api/products/export-excel/
# Body: {"export_type": "all"}
```

---

## API Endpoint Details

### Endpoint
```
POST /api/products/discovery-scrape/
```

### Request Body (all optional)
```json
{
  "keywords": ["smartwatch", "power bank"],
  "pages": 1
}
```

### Response
```json
{
  "status": "success",
  "discovered_count": 25,
  "urls": [
    "https://www.aliexpress.com/item/1005005...",
    "https://www.aliexpress.com/item/1005006...",
    ...
  ],
  "next_step": "Use /api/products/scrape-batch/ to scrape these URLs"
}
```

### Default Keywords (if none provided)
```
wireless earbuds, smartwatch, power bank, usb hub,
phone stand, led light, bluetooth speaker, phone charger,
laptop stand, webcam, keyboard, mouse,
yoga mat, resistance band, dumbbells, water bottle,
desk lamp, storage box, organizer, air purifier,
sunglasses, watch, wallet, phone case,
mini projector, drone, action camera, tripod
```

---

## Next Steps After Discovery

Once you have discovered URLs:

### 1. **Scrape Batch**
```bash
POST /api/products/scrape-batch/

{
  "urls": ["https://www.aliexpress.com/item/..."]
}
```

### 2. **Export to Excel**
```bash
POST /api/products/export-excel/

{
  "export_type": "all"  // or "category" or "high_profit"
}
```

### 3. **Download Excel**
```bash
GET /api/products/download-excel/
```

---

## Troubleshooting

### "pyppeteer not installed"
```bash
pip install pyppeteer
```

### "Module not found: discovery_scraper"
Make sure file is at:
```
core/scrapers/discovery_scraper.py
```

### Timeout (Script takes 1-2 minutes per keyword)
This is normal! Discovery takes time because it:
- Launches browser
- Navigates to pages
- Waits for content to load
- Extracts product links
- Closes browser

**Typical timing:**
- 1 keyword, 1 page = 2-3 minutes
- 5 keywords, 1 page = 10-15 minutes
- 5 keywords, 2 pages = 20-30 minutes

### Django not running
```bash
python manage.py runserver
```

---

## Features

✅ **Automatic Discovery** - No manual URLs needed  
✅ **Keyword-based Search** - Find products by keywords  
✅ **Trending Discovery** - Get trending products  
✅ **Multi-page Support** - Scrape 1-3 pages per source  
✅ **Duplicate Removal** - Unique URLs only  
✅ **Error Handling** - Continues on failures  
✅ **Rate Limiting** - Respectful 2-second delays  
✅ **Logging** - Full debug output  

---

## Architecture

```
discovery_scraper.py
├── DiscoveryScraper (async class)
│   ├── discover_by_keyword()
│   ├── discover_trending()
│   └── discover_all()
└── discover_products_sync() (Django wrapper)
    └── Used by api/views.py endpoint
```

---

## Performance

| Source | Time | Products |
|--------|------|----------|
| 1 Keyword | 2-3 min | 15-25 |
| 5 Keywords | 10-15 min | 75-125 |
| Trending | 2-3 min | 20-30 |
| Total (5 keywords) | 15-20 min | 100-150 |

---

## Integration in views.py

Already added! Just use:

```python
@action(detail=False, methods=['post'], url_path="discovery-scrape")
def discovery_scrape(self, request):
    """Automatically discover products"""
    from core.scrapers.discovery_scraper import discover_products_sync
    result = discover_products_sync(keywords, pages)
    return Response(result)
```

---

## Next Development Steps

1. ✅ Create discovery scraper
2. ✅ Add API endpoint
3. ✅ Create test suite
4. ⏭️ Schedule automatic discovery (Celery)
5. ⏭️ Add filters (min price, max price, min rating)
6. ⏭️ Save discovered products to database
7. ⏭️ Add email alerts for new products

---

**Start testing now:**
```bash
python test_discovery_scraper.py sync
```

Good luck! 🚀
