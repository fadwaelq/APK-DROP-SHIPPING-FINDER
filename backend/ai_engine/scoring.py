"""
AI Scoring Engine for Product Analysis
Analyzes products based on multiple criteria and generates performance scores
"""

import logging
import numpy as np
from typing import Dict, Any, List
from django.conf import settings

logger = logging.getLogger(__name__)


class ProductScorer:
    """AI-powered product scoring system"""
    
    def __init__(self):
        self.weights = settings.AI_SCORING_WEIGHTS
    
    def calculate_score(self, product_data: Dict[str, Any]) -> Dict[str, int]:
        """
        Calculate comprehensive product score
        
        Args:
            product_data: Dictionary containing product metrics
            
        Returns:
            Dictionary with individual scores and overall score
        """
        scores = {
            'demand_level': self._calculate_demand_score(product_data),
            'popularity': self._calculate_popularity_score(product_data),
            'competition': self._calculate_competition_score(product_data),
            'profitability': self._calculate_profitability_score(product_data),
            'trend': self._calculate_trend_score(product_data),
        }
        
        # Calculate weighted overall score
        overall_score = sum(
            scores[key] * self.weights.get(key, 0)
            for key in scores.keys()
        )
        
        scores['overall'] = int(min(100, max(0, overall_score)))
        
        logger.debug(f"Calculated scores for product: {scores}")
        return scores
    
    def _calculate_demand_score(self, data: Dict[str, Any]) -> int:
        """
        Calculate demand level score (0-100)
        Based on search volume, sales velocity, and market interest
        """
        # Simulated demand calculation
        # In production, this would use real market data
        sales_count = data.get('sales_count', 0)
        views_count = data.get('views_count', 0)
        search_volume = data.get('search_volume', 0)
        
        # Normalize values
        sales_score = min(100, (sales_count / 1000) * 100)
        views_score = min(100, (views_count / 10000) * 100)
        search_score = min(100, (search_volume / 5000) * 100)
        
        # Weighted average
        demand_score = (sales_score * 0.5 + views_score * 0.3 + search_score * 0.2)
        
        return int(demand_score)
    
    def _calculate_popularity_score(self, data: Dict[str, Any]) -> int:
        """
        Calculate popularity score (0-100)
        Based on reviews, ratings, and social signals
        """
        review_count = data.get('review_count', 0)
        rating = data.get('rating', 0)
        social_shares = data.get('social_shares', 0)
        
        # Normalize
        review_score = min(100, (review_count / 500) * 100)
        rating_score = (rating / 5) * 100
        social_score = min(100, (social_shares / 1000) * 100)
        
        popularity_score = (review_score * 0.4 + rating_score * 0.4 + social_score * 0.2)
        
        return int(popularity_score)
    
    def _calculate_competition_score(self, data: Dict[str, Any]) -> int:
        """
        Calculate competition score (0-100)
        Lower competition = higher score
        """
        competitor_count = data.get('competitor_count', 0)
        market_saturation = data.get('market_saturation', 0)
        
        # Inverse scoring - less competition is better
        competitor_score = max(0, 100 - (competitor_count / 100) * 100)
        saturation_score = max(0, 100 - market_saturation)
        
        competition_score = (competitor_score * 0.6 + saturation_score * 0.4)
        
        return int(competition_score)
    
    def _calculate_profitability_score(self, data: Dict[str, Any]) -> int:
        """
        Calculate profitability score (0-100)
        Based on profit margin and absolute profit
        """
        price = data.get('price', 0)
        cost = data.get('cost', 0)
        
        if price <= 0 or cost <= 0:
            return 50  # Default score if data is missing
        
        profit = price - cost
        profit_margin = (profit / price) * 100
        
        # Score based on margin and absolute profit
        margin_score = min(100, profit_margin * 2)  # 50% margin = 100 score
        profit_score = min(100, (profit / 50) * 100)  # €50 profit = 100 score
        
        profitability_score = (margin_score * 0.6 + profit_score * 0.4)
        
        return int(profitability_score)
    
    def _calculate_trend_score(self, data: Dict[str, Any]) -> int:
        """
        Calculate trend score (0-100)
        Based on growth rate and momentum
        """
        trend_percentage = data.get('trend_percentage', 0)
        growth_rate = data.get('growth_rate', 0)
        
        # Positive trends score higher
        trend_score = min(100, max(0, 50 + trend_percentage))
        growth_score = min(100, max(0, 50 + growth_rate))
        
        trend_final = (trend_score * 0.6 + growth_score * 0.4)
        
        return int(trend_final)
    
    def analyze_product_potential(self, product_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Comprehensive product analysis with recommendations
        
        Returns:
            Dictionary with scores, insights, and recommendations
        """
        scores = self.calculate_score(product_data)
        
        insights = self._generate_insights(scores, product_data)
        recommendations = self._generate_recommendations(scores)
        risk_level = self._calculate_risk_level(scores)
        
        return {
            'scores': scores,
            'insights': insights,
            'recommendations': recommendations,
            'risk_level': risk_level,
            'is_recommended': scores['overall'] >= 70,
        }
    
    def _generate_insights(self, scores: Dict[str, int], data: Dict[str, Any]) -> List[Dict[str, str]]:
        """Generate actionable insights based on scores"""
        insights = []
        
        if scores['demand_level'] >= 80:
            insights.append({
                'type': 'positive',
                'title': 'Forte demande',
                'message': 'Ce produit bénéficie d\'une demande élevée sur le marché'
            })
        
        if scores['competition'] >= 70:
            insights.append({
                'type': 'positive',
                'title': 'Faible concurrence',
                'message': 'Peu de concurrence sur ce marché - opportunité intéressante'
            })
        
        if scores['profitability'] >= 80:
            insights.append({
                'type': 'positive',
                'title': 'Marge importante',
                'message': 'Potentiel de profit élevé avec de bonnes marges'
            })
        
        trend = data.get('trend_percentage', 0)
        if trend > 20:
            insights.append({
                'type': 'positive',
                'title': 'Tendance à la hausse',
                'message': f'+{trend:.0f}% de croissance récente'
            })
        elif trend < -20:
            insights.append({
                'type': 'warning',
                'title': 'Tendance à la baisse',
                'message': f'{trend:.0f}% de décroissance - prudence recommandée'
            })
        
        return insights
    
    def _generate_recommendations(self, scores: Dict[str, int]) -> List[str]:
        """Generate recommendations based on scores"""
        recommendations = []
        
        if scores['overall'] >= 80:
            recommendations.append("Excellent produit - Lancement recommandé")
        elif scores['overall'] >= 70:
            recommendations.append("Bon produit - Analyser la concurrence locale")
        elif scores['overall'] >= 60:
            recommendations.append("Potentiel moyen - Tester avec petit budget")
        else:
            recommendations.append("Risque élevé - Chercher d'autres opportunités")
        
        if scores['demand_level'] < 50:
            recommendations.append("Augmenter la visibilité avec du marketing ciblé")
        
        if scores['profitability'] < 60:
            recommendations.append("Négocier les prix fournisseurs pour améliorer les marges")
        
        if scores['competition'] < 50:
            recommendations.append("Marché saturé - Différenciation nécessaire")
        
        return recommendations
    
    def _calculate_risk_level(self, scores: Dict[str, int]) -> str:
        """Calculate overall risk level"""
        overall = scores['overall']
        
        if overall >= 80:
            return 'low'
        elif overall >= 60:
            return 'medium'
        else:
            return 'high'


class TrendAnalyzer:
    """Analyze market trends and predict future performance"""
    
    def __init__(self):
        self.scorer = ProductScorer()
    
    def analyze_category_trends(self, category: str, products: List[Dict]) -> Dict[str, Any]:
        """
        Analyze trends for a product category
        
        Args:
            category: Product category
            products: List of product data
            
        Returns:
            Trend analysis with predictions
        """
        if not products:
            return {'status': 'no_data'}
        
        # Calculate average scores
        avg_score = np.mean([p.get('score', 0) for p in products])
        avg_trend = np.mean([p.get('trend_percentage', 0) for p in products])
        
        # Identify top performers
        top_products = sorted(products, key=lambda x: x.get('score', 0), reverse=True)[:5]
        
        return {
            'category': category,
            'average_score': int(avg_score),
            'average_trend': float(avg_trend),
            'total_products': len(products),
            'top_products': top_products,
            'is_growing': avg_trend > 10,
            'recommendation': self._get_category_recommendation(avg_score, avg_trend),
        }
    
    def _get_category_recommendation(self, avg_score: float, avg_trend: float) -> str:
        """Get recommendation for category"""
        if avg_score >= 75 and avg_trend > 15:
            return "Catégorie en forte croissance - Opportunité excellente"
        elif avg_score >= 60 and avg_trend > 0:
            return "Catégorie stable - Bon potentiel"
        elif avg_trend < -10:
            return "Catégorie en déclin - Prudence recommandée"
        else:
            return "Catégorie moyenne - Analyser produits individuels"
    
    def predict_future_performance(self, historical_data: List[Dict]) -> Dict[str, Any]:
        """
        Predict future product performance based on historical data
        
        Args:
            historical_data: List of historical metrics
            
        Returns:
            Prediction with confidence level
        """
        # Simple linear regression for trend prediction
        # In production, use more sophisticated ML models
        
        if len(historical_data) < 2:
            return {'status': 'insufficient_data'}
        
        scores = [d.get('score', 0) for d in historical_data]
        trend = np.polyfit(range(len(scores)), scores, 1)[0]
        
        predicted_score = scores[-1] + (trend * 7)  # 7 days ahead
        confidence = min(100, max(0, 100 - abs(trend) * 10))
        
        return {
            'current_score': scores[-1],
            'predicted_score': int(predicted_score),
            'trend_direction': 'up' if trend > 0 else 'down',
            'confidence': int(confidence),
            'recommendation': 'buy' if predicted_score > 70 else 'wait',
        }
