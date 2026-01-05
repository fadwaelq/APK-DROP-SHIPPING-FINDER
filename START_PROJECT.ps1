# Script de démarrage complet du projet Dropshipping Finder
# Démarre le backend Django et le frontend Flutter

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "🚀 DROPSHIPPING FINDER - Démarrage du Projet" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Démarrer le Backend Django
Write-Host "📦 Démarrage du Backend Django..." -ForegroundColor Yellow
Write-Host ""

$backendPath = "$PSScriptRoot\backend"
$venvPath = "$backendPath\venv\Scripts\Activate.ps1"

# Vérifier si le venv existe
if (Test-Path $venvPath) {
    Write-Host "✅ Environnement virtuel trouvé" -ForegroundColor Green
    
    # Démarrer Django dans un nouveau terminal
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; & '$venvPath'; python manage.py runserver"
    
    Write-Host "✅ Backend Django démarré sur http://localhost:8000" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "❌ Environnement virtuel non trouvé!" -ForegroundColor Red
    Write-Host "Création de l'environnement virtuel..." -ForegroundColor Yellow
    
    cd $backendPath
    python -m venv venv
    & "$venvPath"
    pip install -r requirements.txt
    
    Write-Host "✅ Environnement créé et dépendances installées" -ForegroundColor Green
    
    # Démarrer Django
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; & '$venvPath'; python manage.py runserver"
}

Start-Sleep -Seconds 3

# 2. Démarrer le Frontend Flutter
Write-Host "📱 Démarrage du Frontend Flutter..." -ForegroundColor Yellow
Write-Host ""

$frontendPath = "$PSScriptRoot\frontend"

# Arrêter les processus Flutter existants
Get-Process | Where-Object {$_.ProcessName -like "*dart*"} | ForEach-Object {
    Write-Host "🛑 Arrêt du processus Flutter existant (PID: $($_.Id))" -ForegroundColor Yellow
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 2

# Démarrer Flutter dans un nouveau terminal
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; flutter run -d chrome --web-port=3000"

Write-Host "✅ Frontend Flutter en cours de démarrage..." -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 2

# 3. Afficher les informations
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✅ Projet Démarré avec Succès!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 URLs d'accès:" -ForegroundColor White
Write-Host "   Frontend:  http://localhost:3000" -ForegroundColor Cyan
Write-Host "   Backend:   http://localhost:8000" -ForegroundColor Cyan
Write-Host "   Admin:     http://localhost:8000/admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "👤 Comptes de test:" -ForegroundColor White
Write-Host "   Email:     image@gmail.com" -ForegroundColor Cyan
Write-Host "   Password:  (votre mot de passe)" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 Actions importantes:" -ForegroundColor White
Write-Host "   1. Videz le cache du navigateur (Ctrl+Shift+Delete)" -ForegroundColor Yellow
Write-Host "   2. Ou utilisez la navigation privée (Ctrl+Shift+N)" -ForegroundColor Yellow
Write-Host "   3. Rechargez la page (Ctrl+F5)" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Appuyez sur une touche pour fermer cette fenetre..." -ForegroundColor Gray
Read-Host "Appuyez sur Entree pour continuer"
