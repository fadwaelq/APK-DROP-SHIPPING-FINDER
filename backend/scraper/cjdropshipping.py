import urllib.parse
import random
import re
from playwright.sync_api import sync_playwright

class CJDropshippingSearcher:
    def __init__(self, headless=True):
        self.headless = headless

    def get_first_product_url(self, search_query):
        """Cherche un produit sur CJ Dropshipping et retourne l'URL du premier résultat."""
        # CJ utilise souvent ce format pour ses recherches
        encoded_query = urllib.parse.quote(search_query)
        search_url = f"https://cjdropshipping.com/search/{encoded_query}.html"

        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                viewport={'width': 1280, 'height': 800}
            )
            page = context.new_page()
            
            try:
                page.goto(search_url, wait_until="domcontentloaded", timeout=30000)
                # On attend un peu plus longtemps car CJ est lourd à charger
                page.wait_for_timeout(5000) 
                
                # Les liens produits CJ contiennent généralement '/product-detail/' ou '/product/'
                hrefs = page.evaluate('''() => {
                    const links = Array.from(document.querySelectorAll('a'));
                    return links.map(a => a.href).filter(href => href.includes('cjdropshipping.com/product-detail/'));
                }''')

                if hrefs and len(hrefs) > 0:
                    first_url = hrefs[0].split('?')[0] # Nettoyage de l'URL
                    return first_url
                else:
                    return self._get_mock_search_url()

            except Exception as e:
                print(f"❌ Échec de la recherche CJ Dropshipping: {e}")
                return self._get_mock_search_url()
            finally:
                browser.close()

    def _get_mock_search_url(self):
        fake_id = random.randint(1000000000, 9999999999)
        return f"https://cjdropshipping.com/product-detail/mock-product-p-{fake_id}.html"


class CJDropshippingEngine:
    def __init__(self, headless=True):
        self.headless = headless

    def extract_product_data(self, url):
        """Extrait les données d'une page produit CJ Dropshipping."""
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                viewport={'width': 1280, 'height': 800}
            )
            page = context.new_page()
            
            try:
                page.goto(url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(5000) # Laisse le temps au React/VueJS de s'afficher
                
                # 1. Le Titre (Sélecteurs CJ)
                title = "Produit CJ Dropshipping"
                for selector in ['.product-name', 'h1', '.title']:
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
                    "image": "https://cc-west-usa.oss-accelerate.aliyuncs.com/placeholder.jpg",
                    "source_url": url,
                    "platform": "cjdropshipping" # 👈 Identifiant de la source
                }
            except Exception as e:
                print(f"Scraping CJ Dropshipping failed: {e}")
                return self._get_mock_data(url)
            finally:
                browser.close()

    def _parse_price(self, page):
        """Cherche le prix avec les classes spécifiques à CJ."""
        # CJ utilise souvent des fourchettes de prix ou des classes comme .price-value
        for selector in ['.price', '.product-price', '.sell-price']:
            elem = page.query_selector(selector)
            if elem:
                text = elem.inner_text()
                # Nettoyage pour récupérer le premier nombre trouvé (utile si c'est une fourchette ex: "$10.00 - $15.00")
                match = re.search(r'\d+\.\d+', text.replace(',', '.'))
                if match:
                    return float(match.group())
        return 0.0

    def _get_mock_data(self, url):
        return {
            "title": f"[DEMO] Produit CJ Dropshipping - {random.randint(100, 999)}",
            "price": round(random.uniform(5.0, 40.0), 2),
            "image": "https://cc-west-usa.oss-accelerate.aliyuncs.com/15132596/11492694174330.jpg",
            "source_url": url,
            "platform": "cjdropshipping",
            "warning": "Données simulées"
        }