@echo off
REM ========================================
REM Professional AliExpress Scraper Launcher
REM For Windows Users
REM ========================================

setlocal enabledelayedexpansion

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Navigate to backend folder
cd /d "%~dp0"

echo.
echo ========================================
echo 🚀 ALIEXPRESS SCRAPER LAUNCHER
echo ========================================
echo.

REM Display menu
echo Choose what to do:
echo.
echo 1. Scrape "smartwatch" (2 pages, 50 products)
echo 2. Scrape "wireless earbuds" (2 pages, 50 products)
echo 3. Scrape "phone case" (1 page, 30 products)
echo 4. Custom search
echo 5. View logs
echo 6. Check database
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    echo.
    echo 🔍 Scraping "smartwatch"...
    python scrape_aliexpress_pro.py --query "smartwatch" --pages 2 --limit 50
    goto :success
)

if "%choice%"=="2" (
    echo.
    echo 🔍 Scraping "wireless earbuds"...
    python scrape_aliexpress_pro.py --query "wireless earbuds" --pages 2 --limit 50
    goto :success
)

if "%choice%"=="3" (
    echo.
    echo 🔍 Scraping "phone case"...
    python scrape_aliexpress_pro.py --query "phone case" --pages 1 --limit 30
    goto :success
)

if "%choice%"=="4" (
    set /p query="Enter search keyword: "
    set /p pages="Enter number of pages (1-5): "
    set /p limit="Enter product limit (10-100): "
    
    if not defined pages set pages=2
    if not defined limit set limit=50
    
    echo.
    echo 🔍 Scraping "!query!"...
    python scrape_aliexpress_pro.py --query "!query!" --pages !pages! --limit !limit!
    goto :success
)

if "%choice%"=="5" (
    echo.
    echo 📋 Showing last 50 lines of logs:
    echo.
    if exist scraping.log (
        powershell -Command "Get-Content scraping.log -Tail 50"
    ) else (
        echo ⚠️ No logs found yet. Run a scrape first.
    )
    pause
    goto :end
)

if "%choice%"=="6" (
    echo.
    echo 🗄️ Opening Django Admin...
    echo Please make sure Django server is running first!
    echo.
    python manage.py shell -c "from core.models import Product; print(f'Total products: {Product.objects.count()}')"
    pause
    goto :end
)

echo ❌ Invalid choice
pause
exit /b 1

:success
echo.
echo ✅ Scraping complete!
echo.
echo 📊 To view results:
echo    1. Check Django admin: python manage.py runserver (then visit http://localhost:8000/admin)
echo    2. Check logs: Open scraping.log
echo.
pause
goto :end

:end
endlocal
exit /b 0
