# layer3_scoring/constants.py
# ─────────────────────────────────────────────────────────────────────────────
# All constants, weights, thresholds, and enums for the scoring engine.
# Change weights here — nowhere else.
# ─────────────────────────────────────────────────────────────────────────────

# ── Viral Score Weights (must sum to 1.0) ────────────────────────────────────
VIRAL_WEIGHTS = {
    "wow_score":       0.30,   # visual impact from Layer 1
    "tiktokability":   0.25,   # short-video potential from Layer 1
    "trend_score":     0.20,   # weekly sync signal (0.0–1.0)
    "has_clear_usp":   0.15,   # extracted USP presence from Layer 2
    "problem_clarity": 0.10,   # problem was clearly identified in Layer 2
}

# ── Competition Risk Thresholds ───────────────────────────────────────────────
COMPETITION_THRESHOLDS = {
    "high":   0.75,   # saturation > 0.75 → High risk
    "medium": 0.45,   # saturation > 0.45 → Medium risk
    # below 0.45 → Low risk
}

# ── Margin Potential Thresholds ───────────────────────────────────────────────
# Based on calculated gross margin ratio: (sell_price - costs) / sell_price
MARGIN_THRESHOLDS = {
    "high":   0.60,   # margin > 60% → High
    "medium": 0.35,   # margin > 35% → Medium
    # below 35% → Low
}

# ── Recommended Sell Price Multiplier ────────────────────────────────────────
# sell_price = supplier_price * multiplier
# Adjusted by market type
PRICE_MULTIPLIERS = {
    "mass":    3.5,
    "niche":   4.5,
    "premium": 5.5,
}

# ── ROAS Targets by Margin Level ─────────────────────────────────────────────
ROAS_TARGETS = {
    "high":   2.5,
    "medium": 3.5,
    "low":    5.0,   # low margin → need higher ROAS to be profitable
}

# ── Category Saturation — Local Baseline ─────────────────────────────────────
# Updated via weekly server sync.
# 0.0 = completely unsaturated, 1.0 = completely saturated
DEFAULT_CATEGORY_SATURATION = {
    "gadget":              0.72,
    "beauty":              0.68,
    "home_kitchen":        0.55,
    "fashion_accessories": 0.60,
    "pet_kids":            0.45,
    "fitness_outdoor":     0.50,
}

# ── Marketing Angle → Virality Bonus ─────────────────────────────────────────
# Some angles are inherently more viral — add a small bonus to viral score
ANGLE_VIRALITY_BONUS = {
    "problem_solution": 0.05,
    "transformation":   0.08,
    "social_proof":     0.10,
    "curiosity":        0.07,
    "convenience":      0.03,
    "identity":         0.02,
    "value":            0.01,
}

# ── Score Labels ──────────────────────────────────────────────────────────────
VIRAL_SCORE_LABELS = {
    (8.0, 10.0): "🔥 Viral Potential",
    (6.0,  8.0): "⚡ Strong",
    (4.0,  6.0): "👍 Moderate",
    (0.0,  4.0): "❄️  Weak",
}
