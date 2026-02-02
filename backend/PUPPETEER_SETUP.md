# 🚀 Puppeteer Integration Setup Guide

## ✅ What's Implemented

### **1. Core Scraper Module** (`core/scrapers/puppeteer_scraper.py`)
- Async PuppeteerAliExpressScraper class
- Synchronous PuppeteerScraper wrapper for Django
- Extracts: title, price, images, rating, reviews, sales, description, supplier, shipping, stock
- Handles JavaScript rendering for dynamic prices
- Tor proxy support

### **2. Celery Tasks** (`integrations/tasks.py`)
- `scrape_product_with_puppeteer()` - Single product scraping with retry logic
- `scrape_batch_products()` - Batch scraping with queuing
- Automatic duplicate detection
- Error handling and exponential backoff

### **3. API Endpoints** (`api/views.py`)
- `POST /api/products/scrape-puppeteer/` - Queue single product scrape
- `GET /api/products/scrape-status/{task_id}/` - Check scraping status
- `POST /api/products/scrape-batch/` - Queue batch scraping

### **4. Database Model** (`core/models.py`)
- `ScrapingJob` model for tracking all scraping operations
- Stores URL, status, results, timestamps, and errors
- Includes metadata properties (duration, is_success)

---

## 📦 Installation Steps

### **Step 1: Install Dependencies**

```bash
# Install Python packages
pip install -r requirements.txt

# Install Chromium for pyppeteer
pyppeteer-install
```

### **Step 2: Create Database Migrations**

```bash
# Create migration for new ScrapingJob model
python manage.py makemigrations

# Apply migrations
python manage.py migrate
```

### **Step 3: Setup Environment Variables** (if needed)

Add to `.env`:
```env
# Tor Proxy (optional)
TOR_PROXY_HOST=localhost
TOR_PROXY_PORT=9050

# Celery Configuration
CELERY_BROKER_URL=redis://localhost:6379
CELERY_RESULT_BACKEND=redis://localhost:6379
```

### **Step 4: Start Services**

**Terminal 1: Django Server**
```bash
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2: Celery Worker**
```bash
celery -A dropshipping_finder worker -l info
```

**Terminal 3: Celery Beat** (optional - for scheduled tasks)
```bash
celery -A dropshipping_finder beat -l info
```

**Terminal 4: Redis** (if not running as service)
```bash
redis-server
```

---

## 🧪 Testing

### **Option 1: Quick Test**

```bash
python test_puppeteer_scraping.py
```

### **Option 2: Using Python Shell**

```bash
python manage.py shell
```

```python
# Test synchronous scraping
from core.scrapers.puppeteer_scraper import PuppeteerScraper

scraper = PuppeteerScraper(use_tor=False, headless=True)
data = scraper.scrape_product("https://www.aliexpress.com/item/1005008365025184.html")

print(f"Title: {data['title']}")
print(f"Price: ${data['price']}")
print(f"Rating: {data['rating']}")
```

### **Option 3: Using cURL**

```bash
# 1. Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpass123"
  }'

# Copy the token from response

# 2. Queue scraping task
curl -X POST http://localhost:8000/api/products/scrape-puppeteer/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "url": "https://www.aliexpress.com/item/1005008365025184.html"
  }'

# Response:
# {
#   "status": "queued",
#   "task_id": "abc123def456",
#   "message": "Product scraping started. Check status with task_id",
#   "status_url": "/api/products/scrape-status/abc123def456/"
# }

# 3. Check status
curl -X GET http://localhost:8000/api/products/scrape-status/abc123def456/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### **Option 4: Using Postman**

1. Import `Postman_Collection.json`
2. Set variables:
   - `base_url` = `http://localhost:8000/api`
   - `token` = Your JWT token
3. Use the "Scrape Product" request
4. Check status with "Scrape Status" request

---

## 📊 Usage Examples

### **Single Product Scraping**

```python
import asyncio
from core.scrapers.puppeteer_scraper import PuppeteerAliExpressScraper

async def main():
    scraper = PuppeteerAliExpressScraper(use_tor=True, headless=True)
    await scraper.initialize()
    
    data = await scraper.scrape_product("https://www.aliexpress.com/item/...")
    
    print(f"Title: {data['title']}")
    print(f"Price: ${data['price']}")
    print(f"Images: {len(data['images'])}")
    
    await scraper.close()

# Run
asyncio.run(main())
```

### **Batch Scraping**

```python
from integrations.tasks import scrape_batch_products

urls = [
    "https://www.aliexpress.com/item/1005008365025184.html",
    "https://www.aliexpress.com/item/1005006123456.html",
    "https://www.aliexpress.com/item/1005007890123.html",
]

# Queue batch task
task = scrape_batch_products.delay(urls, user_id=1)
print(f"Batch task ID: {task.id}")
```

### **Check Scraping Status**

```python
from celery.result import AsyncResult

task_id = "abc123def456"
result = AsyncResult(task_id)

print(f"Status: {result.status}")  # PENDING, PROGRESS, SUCCESS, FAILURE
print(f"Result: {result.result}")  # When SUCCESS
print(f"Error: {result.info}")     # When FAILURE
```

### **Access Scraping History**

```python
from core.models import ScrapingJob

# Get all scraping jobs
jobs = ScrapingJob.objects.all()

# Get jobs for specific user
user_jobs = ScrapingJob.objects.filter(user_id=1)

# Get completed jobs
completed = ScrapingJob.objects.filter(status='completed')

# Get failed jobs
failed = ScrapingJob.objects.filter(status='failed')

# Access product created from scraping
for job in jobs:
    if job.product:
        print(f"URL: {job.url}")
        print(f"Product: {job.product.name}")
        print(f"Price: ${job.product.price}")
        print(f"Duration: {job.duration}s")
```

---

## 🔧 Configuration

### **Adjust Timeout**

In `core/scrapers/puppeteer_scraper.py`:
```python
class PuppeteerAliExpressScraper:
    def __init__(self, use_tor=True, headless=True):
        self.timeout = 30000  # Change to adjust (milliseconds)
```

### **Disable Tor Proxy**

For testing without Tor:
```python
scraper = PuppeteerScraper(use_tor=False, headless=True)
```

### **Adjust Retry Logic**

In `integrations/tasks.py`:
```python
@shared_task(bind=True, max_retries=3, time_limit=300)  # Change max_retries
def scrape_product_with_puppeteer(self, url: str, user_id: int = None):
```

---

## 🐛 Troubleshooting

### **Error: "Chromium not found"**

```bash
# Install Chromium
pyppeteer-install

# Or manually download
python -m pyppeteer_install
```

### **Error: "Failed to connect to browser"**

- Check if Tor proxy is running (if `use_tor=True`)
- Try with `use_tor=False` first
- Check system resources (memory, CPU)

### **Error: "Task timeout"**

Increase `time_limit` in task decorator:
```python
@shared_task(bind=True, max_retries=3, time_limit=600)  # 10 minutes
```

### **Error: "Connection refused"**

- Make sure Redis is running
- Check Celery worker is running
- Check Django server is running

### **Price still not extracting**

- AliExpress HTML structure may have changed
- Try updating CSS selectors in `_extract_price()` method
- Add more CSS selectors to try

---

## 📈 Performance Tips

1. **Use headless mode** (default) - much faster than headed
2. **Disable images** - already done in code
3. **Increase Celery workers** for parallel scraping
4. **Use Tor rotation** for multiple scrapes to same site
5. **Set reasonable timeouts** to avoid hanging

---

## 🚀 What's Next

1. ✅ **Single product scraping** - DONE
2. ✅ **Batch scraping** - DONE
3. ✅ **Status tracking** - DONE
4. ⏳ **Auto-category detection** - For enhancement
5. ⏳ **Image downloading** - For enhancement
6. ⏳ **Scheduled scraping** - For enhancement
7. ⏳ **Proxy rotation** - For enhancement

---

## 📝 API Reference

### **POST /api/products/scrape-puppeteer/**
Queue single product scraping task

**Request:**
```json
{
  "url": "https://www.aliexpress.com/item/..."
}
```

**Response (202 Accepted):**
```json
{
  "status": "queued",
  "task_id": "abc123",
  "message": "Product scraping started...",
  "status_url": "/api/products/scrape-status/abc123/"
}
```

### **GET /api/products/scrape-status/{task_id}/**
Check scraping task status

**Response (Success):**
```json
{
  "task_id": "abc123",
  "status": "SUCCESS",
  "result": {
    "status": "success",
    "product_id": 42,
    "created": true,
    "title": "...",
    "price": 12.99
  }
}
```

**Response (Pending):**
```json
{
  "task_id": "abc123",
  "status": "PENDING",
  "message": "Task is pending"
}
```

### **POST /api/products/scrape-batch/**
Queue batch scraping

**Request:**
```json
{
  "urls": [
    "https://www.aliexpress.com/item/...",
    "https://www.aliexpress.com/item/..."
  ]
}
```

**Response (202 Accepted):**
```json
{
  "status": "queued",
  "task_id": "batch123",
  "total_urls": 2,
  "message": "Batch scraping started for 2 products"
}
```

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review logs: `celery -A dropshipping_finder worker -l debug`
3. Check database: `python manage.py dbshell`
4. Verify Puppeteer installation: `python -c "from pyppeteer import launch; print('OK')"`

---

## ✨ Key Features

- ✅ JavaScript rendering (real prices!)
- ✅ Async/concurrent scraping
- ✅ Automatic retry with exponential backoff
- ✅ Duplicate product detection
- ✅ Tor proxy support for anonymity
- ✅ Comprehensive error handling
- ✅ Full audit trail (ScrapingJob model)
- ✅ RESTful API with status tracking
- ✅ Batch processing support
- ✅ Production-ready error recovery

---

**Happy Scraping! 🎉**
