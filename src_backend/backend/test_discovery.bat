@echo off
REM Quick Start Script for Discovery Scraper Testing
REM Run this file to test the discovery scraper

echo.
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║              DISCOVERY SCRAPER - QUICK START                          ║
echo ║                      Choose a test method                             ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.

echo Select test method:
echo.
echo   1. SYNC TEST (Easiest - Recommended)
echo   2. ASYNC TEST (Direct Python async)
echo   3. API TEST (Via REST endpoint)
echo   4. CURL COMMAND (PowerShell)
echo   5. Read Guide
echo   6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    echo.
    echo Running SYNC TEST...
    echo ⏳ This will take 1-2 minutes per keyword...
    echo.
    python test_discovery_scraper.py sync
)

if "%choice%"=="2" (
    echo.
    echo Running ASYNC TEST...
    echo ⏳ This will take 1-2 minutes...
    echo.
    python test_discovery_scraper.py async
)

if "%choice%"=="3" (
    echo.
    echo API TEST requires Django running and JWT token.
    echo.
    set /p token="Enter your JWT token (or leave blank to skip): "
    if not "%token%"=="" (
        python test_discovery_scraper.py api --token %token%
    ) else (
        echo Skipped API test
    )
)

if "%choice%"=="4" (
    echo.
    python test_discovery_scraper.py curl
)

if "%choice%"=="5" (
    echo.
    type DISCOVERY_SCRAPER_GUIDE.md
)

if "%choice%"=="6" (
    exit
)

pause
