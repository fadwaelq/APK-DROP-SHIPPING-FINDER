import random

class AIProcessor:
    """Analyseur intelligent pour calculer la rentabilité (Devise : MAD)."""
    
    @staticmethod
    def analyze(product_data):
        # On s'assure que le prix est en float
        price_mad = float(product_data.get('price', 0))
        
        # Logique métier MVP : Prix de revente suggéré (x3.0 pour couvrir ads + shipping)
        suggested_price_mad = round(price_mad * 3.0, 2)
        profit_mad = round(suggested_price_mad - price_mad, 2)
        
        # Calcul du score de rentabilité et de demande
        profitability_score = 50 
        if profit_mad > 150: profitability_score += 20 # Marge > 150 MAD
        if profit_mad > 300: profitability_score += 20
        
        demand_score = random.randint(40, 90) # Simule Google Trends/TikTok
        
        # Calcul de l'Overall Score (Exigence du MVP)
        overall_score = int((profitability_score + demand_score) / 2)
        
        return {
            "suggested_sale_price": suggested_price_mad,
            "potential_profit": profit_mad,
            "trend_score": overall_score,
            "is_winner": overall_score >= 80,
            "ai_analysis_summary": f"Analyse IA : Produit avec une marge potentielle de {profit_mad} MAD. "
                                   f"Score global de {overall_score}/100. Idéal pour le marché local."
        }