from .engine import AliExpressEngine
from .search_engine import AliExpressSearcher
from .dhgate import DHgateEngine, DHgateSearcher             
from .cjdropshipping import CJDropshippingEngine, CJDropshippingSearcher 
from .ai_engine import ProductAnalyzer
from .models import ScrapingLog
from products.models import Product 

class ScraperService:
    
    @staticmethod
    def is_url(text):
        """Vérifie si le texte fourni ressemble à une URL."""
        return text.startswith('http://') or text.startswith('https://')

    @staticmethod
    def detect_platform(url):
        """Détecte la plateforme à partir de l'URL."""
        if 'dhgate.com' in url:
            return 'dhgate'
        elif 'cjdropshipping.com' in url:
            return 'cjdropshipping'
        else:
            return 'aliexpress' # Par défaut

    @staticmethod
    def get_scraper_classes(platform):
        """Retourne les bonnes classes (Chercheur, Scraper) selon la plateforme."""
        if platform == 'dhgate':
            return DHgateSearcher, DHgateEngine
        elif platform == 'cjdropshipping':
            return CJDropshippingSearcher, CJDropshippingEngine
        else:
            return AliExpressSearcher, AliExpressEngine

    @staticmethod
    # J'ai renommé la fonction pour que ce soit plus logique (import_product au lieu de import_aliexpress_product)
    def import_product(query_or_url, platform="aliexpress"): 
        target_url = query_or_url.strip()

        # ÉTAPE 1 : Détection Titre vs URL
        if not ScraperService.is_url(target_url):
            print(f"🔍 [SERVICE] Recherche par titre sur {platform.upper()} : '{query_or_url}'")
            SearcherClass, _ = ScraperService.get_scraper_classes(platform)
            searcher = SearcherClass(headless=True)
            found_url = searcher.get_first_product_url(query_or_url)
            
            if not found_url:
                return None, f"Impossible de trouver un produit sur {platform} pour : {query_or_url}"
            
            target_url = found_url 
            print(f"🔗 [SERVICE] URL finale trouvée : {target_url}")

        # ÉTAPE 2 : On a une URL. Quelle est la plateforme ?
        detected_platform = ScraperService.detect_platform(target_url)
        _, EngineClass = ScraperService.get_scraper_classes(detected_platform)
        
        print(f"⚙️ [SERVICE] Lancement du scraper pour : {detected_platform.upper()}...")

        log = ScrapingLog.objects.create(url=target_url)
        
        # ÉTAPE 3 : Scraping avec le bon moteur !
        engine = EngineClass(headless=True)
        data = engine.extract_product_data(target_url)
        
        if not data:
            log.status = "failed"
            log.error_message = f"Erreur de scraping sur {detected_platform}"
            log.save()
            return None, f"Erreur de scraping sur {detected_platform}"

        # ÉTAPE 4 : Analyse IA (C'est la même IA pour tous les sites !)
        analysis = ProductAnalyzer.analyze(data)

        # ÉTAPE 5 : Sauvegarde en Base de données
        try:
            product, created = Product.objects.update_or_create(
                # Note: Ton champ s'appelle 'aliexpress_url', on le garde pour l'instant pour ne pas casser ta BDD
                # Mais il contient maintenant aussi les liens DHgate ou CJ !
                aliexpress_url=target_url, 
                defaults={
                    "title": data.get("title"),
                    "price": data.get("price"),
                    "image_url": data.get("image"),
                    "description": data.get("description") or analysis.get("summary", ""),
                    "suggested_sale_price": analysis.get("suggested_price"),
                    "potential_profit": analysis.get("potential_profit"),
                    "trend_score": analysis.get("trend_score"),
                    "is_winner": analysis.get("is_winner"),
                    "ai_analysis_summary": analysis.get("summary", ""),
                }
            )
            log.status = "success"
            log.save()
            return product, None
        except Exception as e:
            log.status = "failed"
            log.error_message = str(e)
            log.save()
            return None, str(e)