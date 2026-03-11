import urllib.parse
import random
import re
from playwright.sync_api import sync_playwright

class DHgateSearcher:
    def __init__(self, headless=True):
        self.headless = headless

    def get_first_product_url(self, search_query):
        """Cherche un produit sur DHgate et retourne l'URL du premier résultat."""
        encoded_query = urllib.parse.quote(search_query)
        # L'URL de recherche spécifique à DHgate
        search_url = f"https://www.dhgate.com/wholesale/search.do?searchkey={encoded_query}"

        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0",
                viewport={'width': 1280, 'height': 800}
            )
            page = context.new_page()
            
            try:
                page.goto(search_url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(4000) # Attente du chargement
                
                # Les liens produits DHgate contiennent généralement '/product/'
                hrefs = page.evaluate('''() => {
                    const links = Array.from(document.querySelectorAll('a'));
                    return links.map(a => a.href).filter(href => href.includes('dhgate.com/product/'));
                }''')

                if hrefs and len(hrefs) > 0:
                    first_url = hrefs[0].split('?')[0] # On nettoie l'URL
                    return first_url
                else:
                    return self._get_mock_search_url()

            except Exception as e:
                print(f"❌ Échec de la recherche DHgate: {e}")
                return self._get_mock_search_url()
            finally:
                browser.close()

    def _get_mock_search_url(self):
        fake_id = random.randint(100000000, 999999999)
        return f"https://www.dhgate.com/product/mock-item/{fake_id}.html"


class DHgateEngine:
    def __init__(self, headless=True):
        self.headless = headless

    def extract_product_data(self, url):
        """Extrait les données d'une page produit DHgate."""
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0",
                viewport={'width': 1280, 'height': 800}
            )
            page = context.new_page()
            
            try:
                page.goto(url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(4000)
                
                # 1. Le Titre (Sélecteurs DHgate)
                title = "Produit DHgate"
                for selector in ['.product-title', 'h1', '[itemprop="name"]']:
                    if page.query_selector(selector):
                        title = page.inner_text(selector)
                        break

                # 2. Le Prix
                price = self._parse_price(page)
                
                if price == 0:
                    return self._get_mock_data(url)

                return {
                    "title": title.strip(),
                    "price": price,
                    "image": "https://image.dhgate.com/placeholder.jpg", # On simplifie avec un placeholder pour l'instant
                    "source_url": url,
                    "platform": "dhgate" # 👈 Nouveau champ pour identifier la source !
                }
            except Exception as e:
                print(f"Scraping DHgate failed: {e}")
                return self._get_mock_data(url)
            finally:
                browser.close()

    def _parse_price(self, page):
        """Cherche le prix avec les classes spécifiques à DHgate."""
        for selector in ['.price', '.j-price', '[itemprop="price"]']:
            elem = page.query_selector(selector)
            if elem:
                text = elem.inner_text()
                digits = re.sub(r'[^\d.]', '', text.replace(',', '.'))
                return float(digits) if digits else 0.0
        return 0.0

    def _get_mock_data(self, url):
        return {
            "title": f"[DEMO] Produit DHgate - {random.randint(100, 999)}",
            "price": round(random.uniform(15.0, 80.0), 2),
            "image": "https://image.dhgate.com/0x0s/f2-albu-g16-M00-5A-7A-rBVaYF-P0uOAIQ2sAAD8-_1_q4837.jpg",
            "source_url": url,
            "platform": "dhgate",
            "warning": "Données simulées"
        }