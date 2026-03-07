import random

class ProductAnalyzer:
    """Analyseur intelligent pour calculer la rentabilité et le score."""
    
    @staticmethod
    def analyze(product_data):
        price = float(product_data.get('price', 0))
        
        # Logique métier : Prix de revente suggéré (x2.5)
        suggested_price = round(price * 2.5, 2)
        profit = round(suggested_price - price, 2)
        
        # Calcul du score de tendance (Heuristique)
        # On booste le score si la marge est > 15€ et le prix d'achat < 20€
        score = 60 # Score de base
        if profit > 15: score += 15
        if price < 20: score += 10
        
        trend_score = min(score + random.randint(0, 10), 100)
        
        return {
            "suggested_price": suggested_price,
            "potential_profit": profit,
            "trend_score": trend_score,
            "is_winner": trend_score >= 80,
            "summary": f"Analyse IA : Produit avec un fort potentiel de marge ({profit}€). "
                       f"Idéal pour publicité Facebook/TikTok."
        }