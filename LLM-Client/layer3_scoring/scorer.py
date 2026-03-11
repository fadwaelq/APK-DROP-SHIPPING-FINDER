# layer3_scoring/scorer.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 3 — Dropshipping Scoring Engine
# ─────────────────────────────────────────────────────────────────────────────
#
# v1: Weighted formula — works today, no training data needed.
# v2: XGBoost model   — plug in when real outcome data is available.
#
# The public API is identical between v1 and v2:
#   scorer = ScoringEngine()
#   result = scorer.score(input_dict)
#
# Usage:
#   from scorer import ScoringEngine
#
#   result = ScoringEngine().score({
#       "layer1": { "category": "beauty", "wow_score": 0.82, ... },
#       "layer2": { "usp": "10x magnification", "marketing_angle": "transformation", ... },
#       "user_input": { "supplier_price": 4.5, "shipping_cost": 2.0, "ad_budget_daily": 20.0 },
#       "trend_score": 0.65,
#   })
#
#   print(result.viral_score)       # 8.4
#   print(result.competition_risk)  # "Medium"
#   print(result.margin_potential)  # "High"
# ─────────────────────────────────────────────────────────────────────────────

from __future__ import annotations
from typing import Optional, Tuple, Union
import json

from models import (
    ScoringInput, ScoringOutput, MarginResult,
    Layer1Output, Layer2Output, UserInput,
)
from constants import (
    VIRAL_WEIGHTS, COMPETITION_THRESHOLDS, MARGIN_THRESHOLDS,
    PRICE_MULTIPLIERS, ROAS_TARGETS, DEFAULT_CATEGORY_SATURATION,
    ANGLE_VIRALITY_BONUS, VIRAL_SCORE_LABELS,
    SEASONALITY_VIRAL_IMPACT, SENTIMENT_VIRAL_IMPACT,
)
from seasonality import SeasonalityScorer


# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

def _clamp(value: float, lo: float = 0.0, hi: float = 1.0) -> float:
    return max(lo, min(hi, value))

def _get_viral_label(score: float) -> str:
    for (low, high), label in VIRAL_SCORE_LABELS.items():
        if low <= score <= high:
            return label
    return "❄️  Weak"

def _get_competition_risk(saturation: float) -> str:
    if saturation > COMPETITION_THRESHOLDS["high"]:
        return "High"
    if saturation > COMPETITION_THRESHOLDS["medium"]:
        return "Medium"
    return "Low"

def _get_margin_label(gross_margin: float) -> str:
    if gross_margin > MARGIN_THRESHOLDS["high"]:
        return "High"
    if gross_margin > MARGIN_THRESHOLDS["medium"]:
        return "Medium"
    return "Low"


# ─────────────────────────────────────────────────────────────────────────────
# VIRAL SCORE CALCULATOR
# ─────────────────────────────────────────────────────────────────────────────

def _compute_viral_score(
    layer1: Layer1Output,
    layer2: Layer2Output,
    trend_score: float,
    seasonality_score: float = 0.5,
    review_sentiment_score: float = 0.5,
) -> float:
    """
    Weighted formula combining Layer 1 + Layer 2 + seasonality + review signals.

    Inputs are all normalized to 0.0–1.0 before weighting.
    Final score is scaled to 0.0–10.0.

    Seasonality and sentiment apply a small multiplier adjustment:
        - Seasonality: (score - 0.5) * SEASONALITY_VIRAL_IMPACT
        - Sentiment:   (score - 0.5) * SENTIMENT_VIRAL_IMPACT
    Both are intentionally modest — they adjust, not dominate.
    """
    has_clear_usp   = 1.0 if layer2.usp else 0.0
    problem_clarity = 1.0 if layer2.problem_solved else 0.0

    raw_score = (
        _clamp(layer1.wow_score)     * VIRAL_WEIGHTS["wow_score"]     +
        _clamp(layer1.tiktokability) * VIRAL_WEIGHTS["tiktokability"]  +
        _clamp(trend_score)          * VIRAL_WEIGHTS["trend_score"]    +
        has_clear_usp                * VIRAL_WEIGHTS["has_clear_usp"]  +
        problem_clarity              * VIRAL_WEIGHTS["problem_clarity"]
    )

    # Apply marketing angle bonus
    angle_bonus = ANGLE_VIRALITY_BONUS.get(layer2.marketing_angle, 0.0)
    raw_score   = _clamp(raw_score + angle_bonus)

    # Apply seasonality adjustment — peak season boosts, off season reduces
    season_adjustment   = (seasonality_score - 0.5) * SEASONALITY_VIRAL_IMPACT
    raw_score           = _clamp(raw_score + season_adjustment)

    # Apply review sentiment adjustment — positive reviews boost slightly
    sentiment_adjustment = (review_sentiment_score - 0.5) * SENTIMENT_VIRAL_IMPACT
    raw_score            = _clamp(raw_score + sentiment_adjustment)

    # Scale to 0–10, round to 1 decimal
    return round(raw_score * 10, 1)


# ─────────────────────────────────────────────────────────────────────────────
# COMPETITION RISK CALCULATOR
# ─────────────────────────────────────────────────────────────────────────────

def _compute_competition_risk(
    category: str,
    market_type: str,
    saturation_override: Optional[float] = None,
) -> Tuple[str, float]:
    """
    Returns (risk_label, saturation_score).
    saturation_override allows the weekly sync to inject fresh data.
    """
    base_saturation = (
        saturation_override
        if saturation_override is not None
        else DEFAULT_CATEGORY_SATURATION.get(category, 0.5)
    )

    # Niche products face less competition regardless of category
    if market_type == "niche":
        saturation = base_saturation * 0.7
    elif market_type == "premium":
        saturation = base_saturation * 0.6
    else:
        saturation = base_saturation

    return _get_competition_risk(saturation), round(saturation, 3)


# ─────────────────────────────────────────────────────────────────────────────
# MARGIN CALCULATOR
# ─────────────────────────────────────────────────────────────────────────────

def _compute_margin(
    user_input: UserInput,
    market_type: str,
) -> MarginResult:
    """
    Calculates margin based on user-entered costs and market type.

    recommended_price = supplier_price * multiplier (from PRICE_MULTIPLIERS)
    gross_margin      = (price - total_cost) / price
    """
    multiplier    = PRICE_MULTIPLIERS.get(market_type, 3.5)
    total_cost    = user_input.supplier_price + user_input.shipping_cost
    rec_price     = round(user_input.supplier_price * multiplier, 2)

    # Protect against zero price
    if rec_price <= 0:
        rec_price = max(total_cost * 2, 0.01)

    gross_margin     = (rec_price - total_cost) / rec_price
    gross_margin     = _clamp(gross_margin)
    profit_per_unit  = round(rec_price - total_cost, 2)
    margin_label     = _get_margin_label(gross_margin)
    roas_target      = ROAS_TARGETS.get(margin_label.lower(), 3.5)

    return MarginResult(
        supplier_price    = user_input.supplier_price,
        shipping_cost     = user_input.shipping_cost,
        total_cost        = round(total_cost, 2),
        recommended_price = rec_price,
        gross_margin      = round(gross_margin, 3),
        gross_margin_pct  = f"{gross_margin * 100:.1f}%",
        profit_per_unit   = profit_per_unit,
        roas_target       = roas_target,
        margin_label      = margin_label,
    )


# ─────────────────────────────────────────────────────────────────────────────
# SCORING ENGINE — PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────

class ScoringEngine:
    """
    Layer 3 Scoring Engine — v1 (weighted formula).

    Accepts a dict or ScoringInput, returns ScoringOutput.

    To upgrade to XGBoost (v2):
      - Subclass this and override _score_impl()
      - Public API stays identical — no changes needed in callers
    """

    def score(self, input_data: Union[dict, ScoringInput]) -> ScoringOutput:
        """
        Main entry point.

        Args:
            input_data: dict with keys layer1, layer2, user_input, trend_score
                        OR a ScoringInput instance

        Returns:
            ScoringOutput with all scores and margin calculations
        """
        if isinstance(input_data, dict):
            scoring_input = ScoringInput.from_dict(input_data)
        else:
            scoring_input = input_data

        return self._score_impl(scoring_input)

    def _score_impl(self, inp: ScoringInput) -> ScoringOutput:
        """Core scoring logic — override this in v2 XGBoost subclass."""

        # 1. Seasonality
        seasonality_result = SeasonalityScorer().score(inp.layer1.category)

        # 2. Viral Score — includes seasonality + review sentiment adjustments
        viral_score = _compute_viral_score(
            inp.layer1,
            inp.layer2,
            inp.trend_score,
            seasonality_score      = seasonality_result.score,
            review_sentiment_score = inp.layer2.review_sentiment_score,
        )
        viral_label = _get_viral_label(viral_score)

        # 3. Competition Risk
        competition_risk, _ = _compute_competition_risk(
            category    = inp.layer1.category,
            market_type = inp.layer1.market_type,
        )

        # 4. Margin
        margin = _compute_margin(inp.user_input, inp.layer1.market_type)

        return ScoringOutput(
            # Core scores
            viral_score      = viral_score,
            viral_label      = viral_label,
            competition_risk = competition_risk,
            margin_potential = margin.margin_label,
            margin           = margin,

            # Seasonality
            seasonality_score  = seasonality_result.score,
            seasonality_label  = seasonality_result.label,
            seasonality_advice = seasonality_result.advice,
            peak_months        = seasonality_result.peak_months,

            # Review sentiment pass-through
            review_sentiment_score = inp.layer2.review_sentiment_score,
            review_sentiment_label = inp.layer2.review_sentiment_label,
            customer_praise        = inp.layer2.customer_praise,
            customer_complaints    = inp.layer2.customer_complaints,
            review_count           = inp.layer2.review_count,

            # Pass-through for Layer 4
            product_name     = inp.layer2.product_name,
            usp              = inp.layer2.usp,
            main_promise     = inp.layer2.main_promise,
            marketing_angle  = inp.layer2.marketing_angle,
            key_features     = inp.layer2.key_features,
            category         = inp.layer1.category,
            market_type      = inp.layer1.market_type,
        )


# ─────────────────────────────────────────────────────────────────────────────
# XGBOOST STUB — ready to implement when outcome data arrives
# ─────────────────────────────────────────────────────────────────────────────

class XGBoostScoringEngine(ScoringEngine):
    """
    v2 scoring engine using XGBoost trained on real product outcomes.

    Drop-in replacement for ScoringEngine — identical public API.

    To activate:
      1. Train the model: python train_xgboost.py --data outcomes.jsonl
      2. Replace ScoringEngine with XGBoostScoringEngine in your imports
      3. Nothing else changes
    """

    def __init__(self, model_path: str = "./xgboost_model.json"):
        self._model_path = model_path
        self._model      = None
        self._load_model()

    def _load_model(self):
        try:
            import xgboost as xgb
            self._model = xgb.XGBRegressor()
            self._model.load_model(self._model_path)
            print(f"XGBoost model loaded from {self._model_path}")
        except (ImportError, OSError, ValueError) as e:
            print(f"XGBoost model not found ({e}) — falling back to weighted formula")
            self._model = None

    def _score_impl(self, inp: ScoringInput) -> ScoringOutput:
        # Fall back to weighted formula if model not loaded
        if self._model is None:
            return super()._score_impl(inp)

        import numpy as np

        # Build feature vector — must match train_xgboost.py feature order
        features = np.array([[
            inp.layer1.wow_score,
            inp.layer1.tiktokability,
            inp.trend_score,
            1.0 if inp.layer2.usp else 0.0,
            1.0 if inp.layer2.problem_solved else 0.0,
            len(inp.layer2.key_features),
            ["mass", "niche", "premium"].index(inp.layer1.market_type),
            list(DEFAULT_CATEGORY_SATURATION.keys()).index(inp.layer1.category)
            if inp.layer1.category in list(DEFAULT_CATEGORY_SATURATION.keys()) else 0,
        ]])

        predicted_viral = float(self._model.predict(features)[0])
        predicted_viral = round(_clamp(predicted_viral, 0.0, 10.0), 1)

        # Everything else still uses the formula
        competition_risk, _ = _compute_competition_risk(
            inp.layer1.category, inp.layer1.market_type
        )
        margin = _compute_margin(inp.user_input, inp.layer1.market_type)

        seasonality_result = SeasonalityScorer().score(inp.layer1.category)

        return ScoringOutput(
            viral_score      = predicted_viral,
            viral_label      = _get_viral_label(predicted_viral),
            competition_risk = competition_risk,
            margin_potential = margin.margin_label,
            margin           = margin,

            seasonality_score  = seasonality_result.score,
            seasonality_label  = seasonality_result.label,
            seasonality_advice = seasonality_result.advice,
            peak_months        = seasonality_result.peak_months,

            review_sentiment_score = inp.layer2.review_sentiment_score,
            review_sentiment_label = inp.layer2.review_sentiment_label,
            customer_praise        = inp.layer2.customer_praise,
            customer_complaints    = inp.layer2.customer_complaints,
            review_count           = inp.layer2.review_count,

            product_name     = inp.layer2.product_name,
            usp              = inp.layer2.usp,
            main_promise     = inp.layer2.main_promise,
            marketing_angle  = inp.layer2.marketing_angle,
            key_features     = inp.layer2.key_features,
            category         = inp.layer1.category,
            market_type      = inp.layer1.market_type,
        )
