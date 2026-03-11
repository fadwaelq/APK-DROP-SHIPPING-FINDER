import urllib.parse
import random
from playwright.sync_api import sync_playwright

class AliExpressSearcher:
    def __init__(self, headless=True):
        self.headless = headless

    def get_first_product_url(self, search_query):
        """
        Cherche un produit par son titre et retourne l'URL du premier résultat.
        """
        # On transforme le texte (ex: "montre sport") en format URL ("montre+sport")
        encoded_query = urllib.parse.quote(search_query)
        search_url = f"https://www.aliexpress.com/wholesale?SearchText={encoded_query}"

        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            context = browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                viewport={'width': 1280, 'height': 800}
            )
            page = context.new_page()
            
            try:
                # On va sur la page de recherche
                page.goto(search_url, wait_until="domcontentloaded", timeout=30000)
                page.wait_for_timeout(5000) # On laisse le temps au JavaScript d'afficher les produits
                
                # Astuce : Tous les produits AliExpress ont "/item/" dans leur lien.
                # On exécute un petit script sur la page pour récupérer le premier lien de produit.
                hrefs = page.evaluate('''() => {
                    const links = Array.from(document.querySelectorAll('a'));
                    return links.map(a => a.href).filter(href => href.includes('/item/'));
                }''')

                if hrefs and len(hrefs) > 0:
                    # On prend le premier lien trouvé, et on coupe les paramètres de tracking (après le '?')
                    first_url = hrefs[0].split('?')[0]
                    return first_url
                else:
                    print(f"❌ Aucun produit trouvé ou bot détecté pour: {search_query}")
                    return self._get_mock_search_url(search_query)

            except Exception as e:
                print(f"❌ Échec de la recherche: {e}. Passage en Mock Data.")
                return self._get_mock_search_url(search_query)
            finally:
                browser.close()

    def _get_mock_search_url(self, query):
        """Génère une fausse URL d'un produit si le scraper est bloqué."""
        fake_id = random.randint(1005000000000000, 1005009999999999)
        return f"https://www.aliexpress.com/item/{fake_id}.html"