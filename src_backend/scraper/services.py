from .engine import AliExpressEngine
from .ai_engine import ProductAnalyzer
from .models import ScrapingLog
from products.models import Product 

class ScraperService:
    @staticmethod
    def import_aliexpress_product(url):
        log = ScrapingLog.objects.create(url=url)
        
        # Scraping
        engine = AliExpressEngine(headless=True)
        data = engine.extract_product_data(url)
        
        if not data:
            return None, "Erreur de scraping"

        # Analyse IA
        analysis = ProductAnalyzer.analyze(data)

        # Sauvegarde enrichie dans Product
        try:
            product, created = Product.objects.update_or_create(
                aliexpress_url=url,
                defaults={
                    "title": data.get("title"),
                    "price": data.get("price"),
                    "image_url": data.get("image"),
                    "description": data.get("description") or analysis["summary"],
                    # Nouveaux champs IA
                    "suggested_sale_price": analysis["suggested_price"],
                    "potential_profit": analysis["potential_profit"],
                    "trend_score": analysis["trend_score"],
                    "is_winner": analysis["is_winner"],
                    "ai_analysis_summary": analysis["summary"],
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