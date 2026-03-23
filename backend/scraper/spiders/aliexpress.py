import requests
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
            print(" ERREUR : Clé API manquante dans le fichier .env")
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
                print(f" [API] Quota dépassé ou clé invalide (Status: {response.status_code})")
                return self._get_mock_data(search_query)

            data = response.json()
            result_list = data.get('result', {}).get('resultList', [])
            
            if not result_list:
                raise ValueError("Aucun produit trouvé.")

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

            print(f" [SUCCÈS] Image récupérée")
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
            print(f" [API FALLBACK] {str(e)}")
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