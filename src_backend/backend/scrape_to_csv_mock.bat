@echo off
REM ==========================================
REM AliExpress CSV Scraper - Mock Version
REM ==========================================
REM Generates realistic mock products to CSV
REM Perfect for testing and development
REM ==========================================

setlocal enabledelayedexpansion

cls
echo.
echo ========================================
echo   ALIEXPRESS CSV SCRAPER - MOCK VERSION
echo   (No network needed - Fast testing)
echo ========================================
echo.

REM Get product search query
set /p query="Enter product to search (default: smartwatch): "
if "!query!"=="" set query=smartwatch

REM Get number of products
set /p count="Enter number of products (default: 50): "
if "!count!"=="" set count=50

REM Get output filename (optional)
set /p output="Enter output filename (default: auto): "

REM Run scraper
echo.
echo Starting mock scraper...
echo Query: !query!
echo Products: !count!
if not "!output!"=="" echo Output: !output!
echo.

if "!output!"=="" (
    python scrape_to_csv_mock.py --query "!query!" --count !count!
) else (
    python scrape_to_csv_mock.py --query "!query!" --count !count! --output "!output!"
)

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   SUCCESS! Check your CSV file.
    echo ========================================
    echo.
    pause
) else (
    echo.
    echo ========================================
    echo   ERROR - Scraper failed
    echo ========================================
    echo.
    pause
)
