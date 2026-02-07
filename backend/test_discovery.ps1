#!/usr/bin/env pwsh
# Quick Start Script for Discovery Scraper Testing (PowerShell)

Write-Host "`n" -ForegroundColor Yellow
Write-Host "╔═══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              DISCOVERY SCRAPER - QUICK START                          ║" -ForegroundColor Cyan
Write-Host "║                      Choose a test method                             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`n" -ForegroundColor Yellow

Write-Host "Select test method:`n" -ForegroundColor Green
Write-Host "  1. SYNC TEST (Easiest - Recommended)" -ForegroundColor Yellow
Write-Host "  2. ASYNC TEST (Direct Python async)" -ForegroundColor Yellow
Write-Host "  3. API TEST (Via REST endpoint)" -ForegroundColor Yellow
Write-Host "  4. CURL COMMAND (PowerShell)" -ForegroundColor Yellow
Write-Host "  5. Read Guide" -ForegroundColor Yellow
Write-Host "  6. Exit`n" -ForegroundColor Yellow

$choice = Read-Host "Enter your choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host "`nRunning SYNC TEST..." -ForegroundColor Green
        Write-Host "⏳ This will take 1-2 minutes per keyword...`n" -ForegroundColor Yellow
        & python test_discovery_scraper.py sync
    }
    
    "2" {
        Write-Host "`nRunning ASYNC TEST..." -ForegroundColor Green
        Write-Host "⏳ This will take 1-2 minutes...`n" -ForegroundColor Yellow
        & python test_discovery_scraper.py async
    }
    
    "3" {
        Write-Host "`nAPI TEST requires Django running and JWT token.`n" -ForegroundColor Yellow
        $token = Read-Host "Enter your JWT token (or leave blank to skip)"
        if ($token -ne "") {
            & python test_discovery_scraper.py api --token $token
        } else {
            Write-Host "Skipped API test" -ForegroundColor Gray
        }
    }
    
    "4" {
        Write-Host "`n" -ForegroundColor Yellow
        & python test_discovery_scraper.py curl
    }
    
    "5" {
        Write-Host "`n" -ForegroundColor Yellow
        Get-Content DISCOVERY_SCRAPER_GUIDE.md
    }
    
    "6" {
        exit
    }
    
    default {
        Write-Host "Invalid choice" -ForegroundColor Red
    }
}

Write-Host "`nPress any key to exit..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
