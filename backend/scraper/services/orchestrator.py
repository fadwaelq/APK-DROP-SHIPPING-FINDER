from scraper.spiders.aliexpress import AliExpressSpider
from scraper.services.ai_processor import AIProcessor

class ScrapingOrchestrator:
    """Orchestre la recherche, le scraping, et l'analyse IA SANS sauvegarder en base."""
    
    @staticmethod
    def run_live_search(query, platform="aliexpress"):
        # 1. Choix du Spider
        if platform == "aliexpress":
            spider = AliExpressSpider(headless=True)
        else:
            raise ValueError(f"Plateforme {platform} non supportée pour le moment.")
        
        # 2. Extraction brute
        raw_data = spider.search_and_extract(query)
        
        # 3. Enrichissement par l'IA
        ai_insights = AIProcessor.analyze(raw_data)
        
        # 4. Fusion des données pour l'aperçu frontend
        preview_data = {**raw_data, **ai_insights}
        
        return preview_data