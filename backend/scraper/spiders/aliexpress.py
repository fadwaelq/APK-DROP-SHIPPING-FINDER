
import requests
import random
import os
from dotenv import load_dotenv

# Charger les variables du fichier .env
load_dotenv()

class AliExpressSpider:
    def __init__(self, headless=True):
        self.api_key = os.getenv("RAPIDAPI_KEY") 
        self.host = os.getenv("RAPIDAPI_HOST", "aliexpress-datahub.p.rapidapi.com")

    def search_and_extract(self, search_query):
        print(f"\n⚡ [API] Recherche via item_search_3 pour : {search_query}")
        
        # Sécurité : vérifier si la clé est bien chargée
        if not self.api_key:
            print("❌ ERREUR : Clé API manquante dans le fichier .env")
            return self._get_mock_data(search_query)

        url = f"https://{self.host}/item_search_3"
        querystring = {"q": search_query, "page": "1", "sort": "default", "region": "US", "currency": "USD"}

        headers = {
            "X-RapidAPI-Key": self.api_key,
            "X-RapidAPI-Host": self.host
        }

        try:
            response = requests.get(url, headers=headers, params=querystring, timeout=10)
            
            # Si l'API renvoie une erreur de quota (429 ou 403)
            if response.status_code in [429, 403]:
                print(f"⚠️ [API] Quota dépassé ou clé invalide (Status: {response.status_code})")
                return self._get_mock_data(search_query)

            data = response.json()
            result_list = data.get('result', {}).get('resultList', [])
            
            if not result_list:
                raise Exception("Aucun produit trouvé.")

            item_data = result_list[0].get('item', {})
            
            # --- LE RESTE DE TON CODE RESTE STRICTEMENT LE MÊME ---
            title = item_data.get('title', 'Produit sans titre')
            sku_def = item_data.get('sku', {}).get('def', {})
            price_usd = float(sku_def.get('promotionPrice') or sku_def.get('price') or 0.0)
            image_url = item_data.get('image', '')
            if image_url.startswith('//'):
                image_url = "https:" + image_url
            source_url = f"https://www.aliexpress.com/item/{item_data.get('itemId')}.html"

            usd_to_mad = 10.45      
            prix_objet_reel_mad = (price_usd * 1.40) * usd_to_mad
            frais_port = 55.0       
            tva_maroc = 1.20        
            cost_mad = (prix_objet_reel_mad + frais_port) * tva_maroc
            selling_price = cost_mad + 150.0 

            print(f"✅ [SUCCÈS] Image récupérée")
            return {
                "title": title,
                "price_aliexpress_usd": price_usd,
                "cost_mad": round(cost_mad, 2),
                "suggested_price_mad": round(selling_price, 2),
                "profit_estimated": round(selling_price - cost_mad, 2),
                "image_url": image_url,
                "source_url": source_url,
                "source_platform": "aliexpress"
            }
            
        except Exception as e:
            print(f"⚠️ [API FALLBACK] {str(e)}")
            return self._get_mock_data(search_query)

    def _get_mock_data(self, query):
        """Données de secours si l'API est en panne ou quota épuisé"""
        return {
            "title": f"[DEMO] {query.capitalize()} Premium",
            "price_aliexpress_usd": 15.0,
            "cost_mad": 180.0,
            "suggested_price_mad": 299.0,
            "profit_estimated": 119.0,
            "image_url": "https://ae01.alicdn.com/kf/Sbc323568894145999f8d5f661138b307W.jpg",
            "source_url": "https://www.aliexpress.com",
            "source_platform": "aliexpress"
        }
""" import requests
import random

class AliExpressSpider:
    def __init__(self, headless=True):
        self.api_key = "2952f6beebmsh5926600814a6213p190cd6jsn7b247ad25c97" 
        self.host = "aliexpress-datahub.p.rapidapi.com"

    def search_and_extract(self, search_query):
        print(f"\n⚡ [API] Recherche via item_search_3 pour : {search_query}")
        
        url = f"https://{self.host}/item_search_3"
        # On force la région US et monnaie USD pour avoir des prix de base stables
        querystring = {"q": search_query, "page": "1", "sort": "default", "region": "US", "currency": "USD"}

        headers = {
            "X-RapidAPI-Key": self.api_key,
            "X-RapidAPI-Host": self.host
        }

        try:
            response = requests.get(url, headers=headers, params=querystring, timeout=10)
            data = response.json()
            result_list = data.get('result', {}).get('resultList', [])
            
            if not result_list:
                raise Exception("Aucun produit trouvé.")

            # On récupère le premier produit
            item_data = result_list[0].get('item', {})
            
            # --- EXTRACTION DES DONNÉES ---
            title = item_data.get('title', 'Produit sans titre')
            
            # Gestion du prix (Promotion ou Standard)
            sku_def = item_data.get('sku', {}).get('def', {})
            price_usd = float(sku_def.get('promotionPrice') or sku_def.get('price') or 0.0)

            # Gestion de la VRAIE image
            image_url = item_data.get('image', '')
            if image_url.startswith('//'):
                image_url = "https:" + image_url

            source_url = f"https://www.aliexpress.com/item/{item_data.get('itemId')}.html"

            # --- CALCULATEUR BUSINESS MAROC (VERSION RÉALITÉ SITE) ---
            usd_to_mad = 10.45      # Taux incluant frais bancaires (dotation e-com)
            
            # 1. AJUSTEMENT MARCHÉ (Le "Secret")
            # AliExpress affiche souvent des prix +30% à +40% élevés pour le Maroc 
            # par rapport au prix de base API. On multiplie donc par 1.4
            prix_objet_reel_mad = (price_usd * 1.40) * usd_to_mad
            
            # 2. FRAIS DE PORT (Shipping)
            # 25 MAD était trop bas. La moyenne pour le Maroc est entre 40 et 70 MAD.
            frais_port = 55.0       
            
            # 3. TVA / DOUANE MAROC (20%)
            tva_maroc = 1.20        
            
            # Coût de revient final (Landed Cost)
            # On applique la TVA sur (Prix Objet + Port)
            cost_mad = (prix_objet_reel_mad + frais_port) * tva_maroc
            
            # 4. PRIX DE VENTE CONSEILLÉ (Marketing)
            # Au lieu d'un % fixe, on ajoute une marge brute de 150 MAD minimum
            selling_price = cost_mad + 150.0 

            print(f"✅ [SUCCÈS] Image récupérée")
            print(f"💰 Nouveau Coût estimé (Proche du site) : {round(cost_mad, 2)} MAD")

            return {
                "title": title,
                "price_aliexpress_usd": price_usd,
                "cost_mad": round(cost_mad, 2),
                "suggested_price_mad": round(selling_price, 2),
                "profit_estimated": round(selling_price - cost_mad, 2),
                "image_url": image_url,
                "source_url": source_url,
                "source_platform": "aliexpress"
            }
            
        except Exception as e:
            print(f"⚠️ [API FALLBACK] {str(e)}")
            return self._get_mock_data(search_query)

    def _get_mock_data(self, query):
        return {
            "title": f"[DEMO] {query.capitalize()} Premium",
            "price_aliexpress_usd": 15.0,
            "cost_mad": 180.0,
            "suggested_price_mad": 299.0,
            "profit_estimated": 119.0,
            "image_url": "https://ae01.alicdn.com/kf/Sbc323568894145999f8d5f661138b307W.jpg",
            "source_url": "https://www.aliexpress.com",
            "source_platform": "aliexpress"
        }
    
"""
# Version alternative avec Playwright pour contourner les limitations de l'API (moins fiable à long terme à cause des anti-bots, mais plus réaliste pour le scraping direct)
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
"""