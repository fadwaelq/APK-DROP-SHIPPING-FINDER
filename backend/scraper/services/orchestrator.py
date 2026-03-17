from scraper.spiders.aliexpress import AliExpressSpider
from scraper.services.ai_processor import AIProcessor
from deep_translator import GoogleTranslator

class ScrapingOrchestrator:
    """Orchestre la recherche, le scraping, et l'analyse IA SANS sauvegarder en base."""
    
    @staticmethod
    def run_live_search(query, platform="aliexpress"):
        # 1. Traduction automatique (FR -> EN) pour maximiser les résultats API
        try:
            query_translated = GoogleTranslator(source='auto', target='en').translate(query)
            print(f"🔄 [ORCHESTRATOR] Traduction : {query} -> {query_translated}")
        except Exception as e:
            print(f"⚠️ [ORCHESTRATOR] Échec traduction : {e}")
            query_translated = query

        # 2. Choix du Spider
        if platform == "aliexpress":
            spider = AliExpressSpider(headless=True)
        else:
            raise ValueError(f"Plateforme {platform} non supportée pour le moment.")
        
        # 3. Extraction brute via RapidAPI
        # Renvoie : title, price_aliexpress_usd, cost_mad, suggested_price_mad, profit_estimated, image_url, etc.
        raw_data = spider.search_and_extract(query_translated)
        
        # 4. MAPPING ET HARMONISATION
        # On aligne les clés pour que l'AIProcessor et le Frontend reçoivent les bonnes infos
        raw_data['suggested_sale_price'] = raw_data.get('suggested_price_mad', 0)
        raw_data['potential_profit'] = raw_data.get('profit_estimated', 0)
        
        # Calcul dynamique du score de tendance (exemple simple)
        raw_data['trend_score'] = 75 
        raw_data['is_winner'] = raw_data['potential_profit'] > 150 # Un "Winner" si > 150 MAD de marge
        
        # 5. Enrichissement par l'IA (Analyse des marges réelles maintenant !)
        ai_insights = AIProcessor.analyze(raw_data)
        
        # 6. Fusion des données finales
        preview_data = {**raw_data, **ai_insights}
        
        print(f"✅ [ORCHESTRATOR] Analyse terminée pour : {raw_data['title'][:30]}...")
        return preview_data