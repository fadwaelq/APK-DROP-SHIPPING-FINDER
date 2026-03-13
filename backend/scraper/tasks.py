from celery import shared_task
import time

@shared_task(bind=True)
def scrape_product_async(self, query):
    """
    Tâche asynchrone gérée par Celery.
    Ici, tu mettras plus tard la logique Playwright.
    """
    print(f"🔄 Démarrage du scraping pour : {query}")
    
    # Simulation d'un traitement long (5 secondes)
    time.sleep(5) 
    
    print("✅ Scraping terminé !")
    
    return {
        "status": "success",
        "query": query,
        "message": "Ceci est un test asynchrone réussi."
    }


@shared_task
def scrape_bulk_async(items, platform='aliexpress'):
    """
    Tâche Celery pour scraper une liste de produits en arrière-plan.
    """
    results = []
    
    for item in items:
        # 1. On simule le temps de scraping pour chaque produit (ex: 3 secondes)
        time.sleep(3) 
        
        # 2. On ajoute le faux résultat au tableau
        results.append({
            "input": item,
            "status": "success",
            "data": {
                "title": f"Produit test pour {item}",
                "platform": platform,
                "price": "15.99"
            }
        })
        
    # On retourne le rapport final avec tous les produits
    return {
        "message": f"{len(items)} produits ont été traités avec succès.",
        "total_items": len(items),
        "results": results
    }