@echo off
REM ========================================
REM Scrape AliExpress to CSV - Windows Launcher
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo 📊 ALIEXPRESS SCRAPER TO CSV
echo ========================================
echo.

REM Default values
set query=smartwatch
set pages=2
set output=aliexpress_products.csv

REM Get user input
set /p query="Enter search keyword (default: smartwatch): "
if "!query!"=="" set query=smartwatch

set /p pages="Enter number of pages (default: 2): "
if "!pages!"=="" set pages=2

set /p output="Enter output filename (default: aliexpress_products.csv): "
if "!output!"=="" set output=aliexpress_products.csv

echo.
echo 🔍 Starting scrape: "!query!"
echo 📄 Pages: !pages!
echo 💾 Output: !output!
echo.

python scrape_to_csv.py --query "!query!" --pages !pages! --output "!output!"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Scraping complete!
    echo 📋 CSV file: !output!
    echo.
    echo Open it with:
    echo   • Excel
    echo   • Google Sheets
    echo   • Any text editor
    echo.
) else (
    echo ❌ Scraping failed
)

pause
