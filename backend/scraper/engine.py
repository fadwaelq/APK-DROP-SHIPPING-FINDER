import re
import random
from playwright.sync_api import sync_playwright

class AliExpressEngine:
    def __init__(self, headless=True):
        self.headless = headless

    def extract_product_data(self, url):
        # --- MODE DÉMO AUTOMATIQUE ---
        # Si on veut éviter d'être bloqué en dev, on peut simuler
        # data = self._get_mock_data(url) 
        # return data

        with sync_playwright() as p:
            # On utilise un navigateur plus "humain"
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                viewport={'width': 1280, 'height': 800}
            )
            page = context.new_page()
            
            try:
                page.goto(url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(5000) # On attend que le JS s'exécute
                
                # On essaie plusieurs sélecteurs pour le titre
                title = "Produit AliExpress"
                for selector in ['h1', '.product-title', '[data-pl="product-title"]']:
                    if page.query_selector(selector):
                        title = page.inner_text(selector)
                        break

                price = self._parse_price(page)
                
                # Si le prix est 0, c'est qu'on est bloqué
                if price == 0:
                    return self._get_mock_data(url)

                data = {
                    "title": title.strip(),
                    "price": price,
                    "image": "https://ae01.alicdn.com/kf/S7b7...jpg", # Exemple
                    "source_url": url,
                }
                return data
            except Exception as e:
                print(f"Scraping failed: {e}. Switching to Mock Data.")
                return self._get_mock_data(url)
            finally:
                browser.close()

    def _get_mock_data(self, url):
        """Génère des données réalistes si le scraper est bloqué."""
        return {
            "title": f"[DEMO] Produit AliExpress - {random.randint(100, 999)}",
            "price": round(random.uniform(10.0, 50.0), 2),
            "image": "https://ae01.alicdn.com/kf/Sbc323568894145999f8d5f661138b307W.jpg",
            "source_url": url,
            "warning": "Données simulées (Bot détecté)"
        }

    def _parse_price(self, page):
        for selector in ['[class*="price--current"]', '.product-price-value', '.price-now']:
            elem = page.query_selector(selector)
            if elem:
                text = elem.inner_text()
                digits = re.sub(r'[^\d.]', '', text.replace(',', '.'))
                return float(digits) if digits else 0.0
        return 0.0