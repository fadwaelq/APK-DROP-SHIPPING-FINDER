# Development Environment Startup Script
Write-Host "=== Dropshipping Finder - Development Startup ===" -ForegroundColor Cyan

# Check if ports are in use
Write-Host "`nChecking ports..." -ForegroundColor Yellow
$port8000 = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
$port3000 = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue

if ($port8000) {
    Write-Host "⚠️  Port 8000 is already in use (Django backend)" -ForegroundColor Red
    Write-Host "   Process ID: $($port8000.OwningProcess)" -ForegroundColor Gray
} else {
    Write-Host "✓ Port 8000 is available" -ForegroundColor Green
}

if ($port3000) {
    Write-Host "⚠️  Port 3000 is already in use (Flutter web)" -ForegroundColor Red
    Write-Host "   Process ID: $($port3000.OwningProcess)" -ForegroundColor Gray
} else {
    Write-Host "✓ Port 3000 is available" -ForegroundColor Green
}

Write-Host "`n=== Starting Services ===" -ForegroundColor Cyan

# Start Django Backend
Write-Host "`n1. Starting Django backend on port 8000..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\backend'; python manage.py runserver 8000"

Start-Sleep -Seconds 3

# Start Flutter Web
Write-Host "2. Starting Flutter web on port 3000..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\frontend'; flutter run -d chrome --web-port 3000"

Write-Host "`n✓ Services starting in separate windows" -ForegroundColor Green
Write-Host "`nBackend API: http://localhost:8000/api" -ForegroundColor Cyan
Write-Host "Frontend:    http://localhost:3000" -ForegroundColor Cyan
Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
