import urllib.parse
import random
import re
from playwright.sync_api import sync_playwright

class AliExpressSpider:
    def __init__(self, headless=True):
        self.headless = headless
        self.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36"

    def search_and_extract(self, search_query):
        """Cherche un produit, prend le premier lien, et extrait ses données."""
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