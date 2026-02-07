# Professional AliExpress Scraper Launcher (PowerShell)
# For Windows Users

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🚀 ALIEXPRESS SCRAPER LAUNCHER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Python
try {
    python --version | Out-Null
} catch {
    Write-Host "❌ Python is not installed or not in PATH" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Menu
Write-Host "Choose what to do:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Scrape 'smartwatch' (2 pages, 50 products)" -ForegroundColor White
Write-Host "2. Scrape 'wireless earbuds' (2 pages, 50 products)" -ForegroundColor White
Write-Host "3. Scrape 'phone case' (1 page, 30 products)" -ForegroundColor White
Write-Host "4. Custom search" -ForegroundColor White
Write-Host "5. View logs" -ForegroundColor White
Write-Host "6. Check database stats" -ForegroundColor White
Write-Host "7. View last 10 products" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-7)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🔍 Scraping 'smartwatch'..." -ForegroundColor Yellow
        Write-Host ""
        & python scrape_aliexpress_pro.py --query "smartwatch" --pages 2 --limit 50
        break
    }
    "2" {
        Write-Host ""
        Write-Host "🔍 Scraping 'wireless earbuds'..." -ForegroundColor Yellow
        Write-Host ""
        & python scrape_aliexpress_pro.py --query "wireless earbuds" --pages 2 --limit 50
        break
    }
    "3" {
        Write-Host ""
        Write-Host "🔍 Scraping 'phone case'..." -ForegroundColor Yellow
        Write-Host ""
        & python scrape_aliexpress_pro.py --query "phone case" --pages 1 --limit 30
        break
    }
    "4" {
        $query = Read-Host "Enter search keyword"
        $pages = Read-Host "Enter number of pages (1-5)"
        $limit = Read-Host "Enter product limit (10-100)"
        
        if ([string]::IsNullOrWhiteSpace($pages)) { $pages = 2 }
        if ([string]::IsNullOrWhiteSpace($limit)) { $limit = 50 }
        
        Write-Host ""
        Write-Host "🔍 Scraping '$query'..." -ForegroundColor Yellow
        Write-Host ""
        & python scrape_aliexpress_pro.py --query "$query" --pages $pages --limit $limit
        break
    }
    "5" {
        Write-Host ""
        Write-Host "📋 Last 30 lines of logs:" -ForegroundColor Yellow
        Write-Host ""
        if (Test-Path "scraping.log") {
            Get-Content scraping.log -Tail 30
        } else {
            Write-Host "⚠️ No logs found. Run a scrape first." -ForegroundColor Yellow
        }
        Write-Host ""
        Read-Host "Press Enter to continue"
        break
    }
    "6" {
        Write-Host ""
        Write-Host "🗄️ Database Stats:" -ForegroundColor Yellow
        Write-Host ""
        python manage.py shell -c @'
from core.models import Product
from django.db.models import Q

total = Product.objects.count()
by_category = Product.objects.values('category').annotate(count=__import__('django.db.models', fromlist=['Count']).Count('id'))
trending = Product.objects.filter(is_trending=True).count()
avg_price = Product.objects.aggregate(__import__('django.db.models', fromlist=['Avg']).Avg('price'))['price__avg']

print(f"📊 Total Products: {total}")
print(f"📈 Trending: {trending}")
print(f"💰 Average Price: ${avg_price:.2f}" if avg_price else "💰 Average Price: N/A")
print(f"\nBy Category:")
for cat in by_category:
    print(f"  • {cat['category']}: {cat['count']}")
'@
        Write-Host ""
        Read-Host "Press Enter to continue"
        break
    }
    "7" {
        Write-Host ""
        Write-Host "🆕 Last 10 Products Added:" -ForegroundColor Yellow
        Write-Host ""
        python manage.py shell -c @'
from core.models import Product

products = Product.objects.order_by('-last_scraped_at')[:10]
for i, p in enumerate(products, 1):
    print(f"{i}. {p.name[:50]}")
    print(f"   Price: ${p.price} | Category: {p.category} | Rating: {p.supplier_rating}/5")
    print()
'@
        Read-Host "Press Enter to continue"
        break
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "✅ Done!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 To view results:" -ForegroundColor Cyan
Write-Host "   1. Check Django admin: python manage.py runserver" -ForegroundColor White
Write-Host "   2. Visit: http://localhost:8000/admin" -ForegroundColor White
Write-Host "   3. Check logs: Type 5 in this menu" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
