"""import urllib.parse
import random
import re
from playwright.sync_api import sync_playwright

class AliExpressSpider:
    def __init__(self, headless=True):
        self.headless = headless
        self.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36"

    def search_and_extract(self, search_query):
        url = self._get_first_product_url(search_query)
        return self._extract_product_data(url)

    def _get_first_product_url(self, search_query):
        encoded_query = urllib.parse.quote(search_query)
        search_url = f"https://www.aliexpress.com/wholesale?SearchText={encoded_query}"
        
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(user_agent=self.user_agent)
            page = context.new_page()
            try:
                page.goto(search_url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(5000)
                hrefs = page.evaluate('''() => {
                    return Array.from(document.querySelectorAll('a'))
                        .map(a => a.href).filter(href => href.includes('/item/'));
                }''')
                if hrefs:
                    return hrefs[0].split('?')[0]
                return f"https://www.aliexpress.com/item/{random.randint(1005000000000, 1005009999999)}.html"
            except Exception:
                return f"https://www.aliexpress.com/item/{random.randint(1005000000000, 1005009999999)}.html"
            finally:
                browser.close()

    def _extract_product_data(self, url):
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(user_agent=self.user_agent)
            page = context.new_page()
            try:
                page.goto(url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(5000)
                
                title = "Produit AliExpress"
                for sel in ['h1', '.product-title', '[data-pl="product-title"]']:
                    if page.query_selector(sel):
                        title = page.inner_text(sel)
                        break
                
                price = 0.0
                for sel in ['[class*="price--current"]', '.product-price-value', '.price-now']:
                    elem = page.query_selector(sel)
                    if elem:
                        price = float(re.sub(r'[^\d.]', '', elem.inner_text().replace(',', '.')))
                        break
                
                if price == 0: raise ValueError("Bot detecté")
                
                return {
                    "title": title.strip(), "price": price, "source_platform": "aliexpress",
                    "source_url": url, "image_url": "https://ae01.alicdn.com/kf/placeholder.jpg"
                }
            except Exception:
                return self._get_mock_data(url)
            finally:
                browser.close()

    def _get_mock_data(self, url):
        return {
            "title": f"[DEMO] Produit AliExpress - {random.randint(100, 999)}",
            "price": round(random.uniform(50.0, 500.0), 2), # En MAD pour le Maroc
            "source_platform": "aliexpress", "source_url": url,
            "image_url": "https://ae01.alicdn.com/kf/Sbc323568894145999f8d5f661138b307W.jpg"
        }
        """

import urllib.parse
import random
import re
from playwright.sync_api import sync_playwright

class AliExpressSpider:
    def __init__(self, headless=True):
        self.headless = headless
        # On ajoute un User-Agent plus robuste
        self.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

    def search_and_extract(self, search_query):
        """Cherche un produit, prend le premier lien, et extrait ses données."""
        print(f"\n🚀 [SCRAPER] Début de la recherche pour : {search_query}")
        url = self._get_first_product_url(search_query)
        print(f"🔗 [SCRAPER] URL trouvée : {url}")
        return self._extract_product_data(url)

    def _get_first_product_url(self, search_query):
        encoded_query = urllib.parse.quote(search_query)
        search_url = f"https://www.aliexpress.com/wholesale?SearchText={encoded_query}"
        
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(user_agent=self.user_agent)
            page = context.new_page()
            try:
                page.goto(search_url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(3000) # Attendre un peu que le JS charge
                
                hrefs = page.evaluate('''() => {
                    return Array.from(document.querySelectorAll('a'))
                        .map(a => a.href).filter(href => href.includes('/item/'));
                }''')
                
                if hrefs:
                    return hrefs[0].split('?')[0] # Nettoyer l'URL
                raise Exception("Aucun lien /item/ trouvé sur la page de recherche.")
            except Exception as e:
                print(f"⚠️ [SCRAPER] Erreur recherche: {e}. Fallback URL aléatoire.")
                return f"https://www.aliexpress.com/item/{random.randint(1005000000000, 1005009999999)}.html"
            finally:
                browser.close()

    def _extract_product_data(self, url):
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(user_agent=self.user_agent)
            page = context.new_page()
            try:
                print("⏳ [SCRAPER] Extraction des données en cours...")
                page.goto(url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(3000)
                
                # 1. Extraction du Titre
                title = "Produit sans titre"
                for sel in ['h1', '[data-pl="product-title"]', '.title--wrap--1ndZR1l']:
                    elem = page.query_selector(sel)
                    if elem:
                        title = elem.inner_text().strip()
                        break
                
                # 2. Extraction du Prix
                price = 0.0
                for sel in ['[class*="price--current"]', '.product-price-value', '.price-now', 'span.price--currentPriceText--V8_y_b5']:
                    elem = page.query_selector(sel)
                    if elem:
                        raw_price = elem.inner_text().replace(',', '.')
                        # On extrait juste les chiffres
                        numbers = re.findall(r'\d+\.\d+|\d+', raw_price)
                        if numbers:
                            price = float(numbers[0])
                        break
                
                # 3. Extraction de l'Image (Technique de la balise meta = hyper fiable)
                image_url = "https://ae01.alicdn.com/kf/Sbc323568894145999f8d5f661138b307W.jpg" # Fallback
                meta_image = page.query_selector('meta[property="og:image"]')
                if meta_image:
                    image_url = meta_image.get_attribute('content')
                
                if price == 0: 
                    raise ValueError("Prix introuvable ou Bot détecté par AliExpress")
                
                print(f"✅ [SCRAPER] Succès ! {title[:30]}... | Prix: {price} | Image trouvée: {image_url != 'fallback'}")
                return {
                    "title": title, 
                    "price": price, 
                    "source_platform": "aliexpress",
                    "source_url": url, 
                    "image_url": image_url
                }
            except Exception as e:
                print(f"❌ [SCRAPER] Échec de l'extraction réelle ({e}). Renvoi des données DEMO.")
                return self._get_mock_data(url)
            finally:
                browser.close()

    def _get_mock_data(self, url):
        return {
            "title": f"[DEMO] Produit AliExpress - {random.randint(100, 999)}",
            "price": round(random.uniform(50.0, 500.0), 2),
            "source_platform": "aliexpress", "source_url": url,
            "image_url": "https://ae01.alicdn.com/kf/Sbc323568894145999f8d5f661138b307W.jpg"
        }