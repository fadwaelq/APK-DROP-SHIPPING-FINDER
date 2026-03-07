#!/usr/bin/env pwsh
# AliExpress Scraper - PowerShell Script
# Usage: powershell .\run_scraper.ps1

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  AliExpress Multi-Category Scraper v2 (Enhanced)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
try {
    python --version | Out-Null
} catch {
    Write-Host "ERROR: Python not found. Install from python.org" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Playwright is installed
Write-Host "Checking dependencies..." -ForegroundColor Yellow
$playwrightCheck = python -c "import playwright" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing Playwright..." -ForegroundColor Yellow
    pip install playwright
    
    Write-Host "Installing Chromium..." -ForegroundColor Yellow
    playwright install chromium
    Write-Host ""
}

# Check if in correct directory
if (-not (Test-Path "core\scrapers\ss.py")) {
    Write-Host "ERROR: Cannot find core\scrapers\ss.py" -ForegroundColor Red
    Write-Host "Make sure you're in the backend directory" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "✅ Setup verified. Starting scraper..." -ForegroundColor Green
Write-Host ""
Write-Host "Output files:" -ForegroundColor Cyan
Write-Host "  - aliexpress_products_multicategory.json (products)" -ForegroundColor Gray
Write-Host "  - aliexpress_scraper_multicategory.log (logs)" -ForegroundColor Gray
Write-Host "  - scraper_state.json (progress)" -ForegroundColor Gray
Write-Host ""

# Run the scraper
python core\scrapers\ss.py

# Check exit code
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Scraper failed. Check logs above." -ForegroundColor Red
} else {
    Write-Host ""
    Write-Host "✅ Scraper completed successfully!" -ForegroundColor Green
    Write-Host "Check aliexpress_products_multicategory.json for results" -ForegroundColor Green
}

Read-Host "Press Enter to exit"
