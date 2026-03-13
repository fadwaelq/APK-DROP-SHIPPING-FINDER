# Script d'import automatique de produits
# Importe des produits depuis AliExpress

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "📦 DROPSHIPPING FINDER - Import de Produits" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$backendPath = "C:\Users\DELL\CascadeProjects\dropshipping-finder\backend"
$venvPath = "$backendPath\venv\Scripts\Activate.ps1"

# Activer l'environnement virtuel
if (Test-Path $venvPath) {
    Write-Host "✅ Activation de l'environnement virtuel..." -ForegroundColor Green
    & $venvPath
    
    cd $backendPath
    
    Write-Host ""
    Write-Host "🔍 Que voulez-vous importer?" -ForegroundColor Yellow
    Write-Host "1. Produits tendance (catégories populaires)" -ForegroundColor White
    Write-Host "2. Recherche personnalisée" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Votre choix (1 ou 2)"
    
    if ($choice -eq "1") {
        Write-Host ""
        Write-Host "📈 Import des produits tendance..." -ForegroundColor Yellow
        Write-Host "Catégories: phone accessories, smart watch, wireless earbuds, etc." -ForegroundColor Gray
        Write-Host ""
        
        python manage.py import_products --trending
        
    } elseif ($choice -eq "2") {
        Write-Host ""
        $query = Read-Host "Entrez votre recherche (ex: wireless earbuds)"
        $pages = Read-Host "Nombre de pages à scraper (1-5, défaut: 2)"
        
        if ([string]::IsNullOrEmpty($pages)) {
            $pages = 2
        }
        
        Write-Host ""
        Write-Host "🔍 Recherche: $query" -ForegroundColor Yellow
        Write-Host "📄 Pages: $pages" -ForegroundColor Yellow
        Write-Host ""
        
        python manage.py import_products "$query" --pages=$pages --no-tor
        
    } else {
        Write-Host "❌ Choix invalide!" -ForegroundColor Red
    }
    
} else {
    Write-Host "❌ Environnement virtuel non trouvé!" -ForegroundColor Red
    Write-Host "Veuillez d'abord exécuter START_PROJECT.ps1" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
Read-Host "Appuyez sur Entree pour continuer"
