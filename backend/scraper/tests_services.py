import pytest
from scraper.services.ai_processor import AIProcessor

def test_ai_processor_analyze():
    product_data = {"cost_mad": 50.0}
    result = AIProcessor.analyze(product_data)
    assert result["suggested_sale_price"] == pytest.approx(150.0)
    assert result["potential_profit"] == pytest.approx(100.0)
    assert "trend_score" in result
    assert isinstance(result["is_winner"], bool)

def test_ai_processor_analyze_expensive():
    product_data = {"cost_mad": 300.0}
    result = AIProcessor.analyze(product_data)
    assert result["suggested_sale_price"] == pytest.approx(550.0)
    assert result["potential_profit"] == pytest.approx(250.0)
