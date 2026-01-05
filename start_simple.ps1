# Simple startup script for Dropshipping Finder
Write-Host "Starting Dropshipping Finder..." -ForegroundColor Cyan

# Start Django Backend
Write-Host "Starting Django backend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\backend'; python manage.py runserver"

Start-Sleep -Seconds 3

# Start Flutter Web
Write-Host "Starting Flutter web..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\frontend'; flutter run -d chrome --web-port=3000"

Write-Host "Services started!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Test account: test@test.com / test123456" -ForegroundColor Yellow

pause
