import random

class AIProcessor:
    """Analyseur intelligent pour calculer la rentabilité (Devise : MAD)."""
    
    @staticmethod
    def analyze(product_data):
        # On utilise 'cost_mad' (le prix d'achat calculé par le spider)
        # Si absent, on essaie 'price', sinon 0.
        cost_mad = float(product_data.get('cost_mad', product_data.get('price', 0)))
        
        # --- Logique de Prix de Vente (Stratégie Maroc) ---
        # Si le produit coûte cher (> 200 DH), on ne fait pas x3 (trop cher).
        # On ajoute une marge fixe confortable pour la publicité et le profit.
        if cost_mad < 100:
            suggested_price_mad = round(cost_mad * 3.0, 2) # Petit prix : gros coeff
        elif cost_mad < 250:
            suggested_price_mad = round(cost_mad * 2.2, 2) # Prix moyen : coeff modéré
        else:
            suggested_price_mad = round(cost_mad + 250.0, 2) # Prix élevé : Marge fixe de 250 DH
            
        profit_mad = round(suggested_price_mad - cost_mad, 2)
        
        # --- Calcul du Score de Rentabilité ---
        profitability_score = 40 
        if profit_mad > 100: profitability_score += 20 
        if profit_mad > 200: profitability_score += 30
        
        # Simulation de la demande (On pourra lier ça à une API de tendances plus tard)
        demand_score = random.randint(50, 95) 
        
        # Score global
        overall_score = int((profitability_score + demand_score) / 2)
        
        return {
            "suggested_sale_price": suggested_price_mad,
            "potential_profit": profit_mad,
            "trend_score": overall_score,
            "is_winner": overall_score >= 80,
            "ai_analysis_summary": f"Analyse IA : Ce produit dégage une marge nette estimée de {profit_mad} MAD après douane. "
                                   f"Avec un score de {overall_score}/100, c'est un excellent candidat pour le marché marocain."
        }