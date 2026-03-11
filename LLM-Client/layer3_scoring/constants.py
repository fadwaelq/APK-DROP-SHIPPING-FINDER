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

# ── Seasonality Multiplier Applied to Viral Score ─────────────────────────────
# Final viral_score = raw_viral_score * (1 + (seasonality_score - 0.5) * SEASONALITY_IMPACT)
# Impact is intentionally modest — seasonality adjusts, not dominates.
SEASONALITY_VIRAL_IMPACT = 0.15

# ── Seasonality Score Labels ──────────────────────────────────────────────────
SEASONALITY_LABELS = {
    (0.8, 1.0): "Peak Season 🔥",
    (0.6, 0.8): "Good Season ✅",
    (0.4, 0.6): "Average ☁️",
    (0.0, 0.4): "Off Season ❄️",
}

# ── Monthly Seasonality Scores Per Category ───────────────────────────────────
# Key: category → dict of month (1-12) → score (0.0 to 1.0)
# Sources: e-commerce seasonal trend data (Google Trends, AliExpress sales cycles)
SEASONALITY_TABLE = {
    "fitness_outdoor": {
        1: 0.95,  # January — New Year resolutions peak
        2: 0.80,  # February — still strong
        3: 0.75,  # March — spring motivation
        4: 0.65,  # April — outdoor season begins
        5: 0.60,  # May — moderate
        6: 0.55,  # June — summer plateau
        7: 0.50,  # July — holiday slowdown
        8: 0.55,  # August — back to routine
        9: 0.65,  # September — autumn motivation
        10: 0.60, # October — pre-winter prep
        11: 0.70, # November — Black Friday + gift season
        12: 0.75, # December — Christmas gifts
    },
    "gadget": {
        1: 0.55,  # January — post-holiday slowdown
        2: 0.50,  # February — low
        3: 0.55,  # March — slight uptick
        4: 0.60,  # April — moderate
        5: 0.60,  # May — stable
        6: 0.55,  # June — summer plateau
        7: 0.55,  # July — steady
        8: 0.60,  # August — back to school gadgets
        9: 0.65,  # September — autumn buying
        10: 0.75, # October — pre-Black Friday builds
        11: 0.95, # November — Black Friday / Cyber Monday peak
        12: 0.90, # December — Christmas gift peak
    },
    "beauty": {
        1: 0.65,  # January — New Year self-care
        2: 0.85,  # February — Valentine's Day peak
        3: 0.70,  # March — spring refresh
        4: 0.65,  # April — steady
        5: 0.70,  # May — Mother's Day
        6: 0.60,  # June — summer plateau
        7: 0.55,  # July — holiday slowdown
        8: 0.60,  # August — back to routine
        9: 0.65,  # September — autumn beauty routines
        10: 0.70, # October — pre-holiday prep
        11: 0.85, # November — Black Friday beauty deals
        12: 0.90, # December — gift sets peak
    },
    "home_kitchen": {
        1: 0.70,  # January — New Year home reset
        2: 0.60,  # February — moderate
        3: 0.65,  # March — spring cleaning
        4: 0.70,  # April — spring home projects
        5: 0.75,  # May — Mother's Day + home upgrades
        6: 0.65,  # June — steady
        7: 0.55,  # July — summer slowdown
        8: 0.60,  # August — back to home routine
        9: 0.65,  # September — autumn nesting
        10: 0.70, # October — pre-holiday kitchen prep
        11: 0.85, # November — Black Friday home deals
        12: 0.90, # December — Christmas gifts peak
    },
    "fashion_accessories": {
        1: 0.60,  # January — post-holiday low
        2: 0.80,  # February — Valentine's Day gifts
        3: 0.70,  # March — spring fashion
        4: 0.75,  # April — spring wardrobe refresh
        5: 0.70,  # May — steady
        6: 0.65,  # June — summer accessories
        7: 0.60,  # July — holiday plateau
        8: 0.65,  # August — back to school fashion
        9: 0.80,  # September — autumn fashion peak
        10: 0.75, # October — autumn wardrobe
        11: 0.85, # November — Black Friday fashion
        12: 0.90, # December — Christmas gift peak
    },
    "pet_kids": {
        1: 0.60,  # January — post-holiday
        2: 0.55,  # February — low
        3: 0.60,  # March — steady
        4: 0.65,  # April — Easter / spring
        5: 0.65,  # May — steady
        6: 0.60,  # June — summer
        7: 0.55,  # July — holiday slowdown
        8: 0.65,  # August — back to school
        9: 0.65,  # September — steady
        10: 0.70, # October — Halloween
        11: 0.85, # November — Black Friday toys
        12: 0.95, # December — Christmas toys peak
    },
}

# ── Seasonality Advice Templates ──────────────────────────────────────────────
# {month} = current month name, {peak} = best month name for this category
SEASONALITY_ADVICE = {
    "fitness_outdoor": {
        "peak":    "{month} is peak season for fitness products — launch now for maximum sales.",
        "good":    "{month} is a good time for fitness products. Demand is solid.",
        "average": "Demand is average in {month}. Consider launching closer to {peak}.",
        "off":     "Off season for fitness in {month}. Best to wait until {peak}.",
    },
    "gadget": {
        "peak":    "{month} is peak gadget season — Black Friday / Christmas demand is highest.",
        "good":    "Good timing for gadgets in {month}. Demand is building.",
        "average": "Average demand for gadgets in {month}. Peak arrives around {peak}.",
        "off":     "Low season for gadgets in {month}. Consider launching closer to {peak}.",
    },
    "beauty": {
        "peak":    "{month} is peak beauty season — Valentine's Day / Christmas gift demand is highest.",
        "good":    "Good timing for beauty products in {month}. Demand is strong.",
        "average": "Average beauty demand in {month}. Peak is around {peak}.",
        "off":     "Slower period for beauty in {month}. Consider waiting until {peak}.",
    },
    "home_kitchen": {
        "peak":    "{month} is peak season for home and kitchen products — gift demand is highest.",
        "good":    "Good timing for home products in {month}. Spring and holiday demand is building.",
        "average": "Average demand for home products in {month}. Peak arrives around {peak}.",
        "off":     "Slower period for home products in {month}. Consider launching closer to {peak}.",
    },
    "fashion_accessories": {
        "peak":    "{month} is peak for fashion accessories — Valentine's Day and Christmas drive gift demand.",
        "good":    "Good timing for accessories in {month}. Seasonal demand is solid.",
        "average": "Average demand for accessories in {month}. Peak is around {peak}.",
        "off":     "Lower demand for accessories in {month}. Consider waiting until {peak}.",
    },
    "pet_kids": {
        "peak":    "{month} is peak season for pet and kids products — Christmas gift demand is highest.",
        "good":    "Good timing for pet and kids products in {month}. Demand is building.",
        "average": "Average demand in {month} for this category. Peak is around {peak}.",
        "off":     "Slower period in {month}. Consider launching closer to {peak}.",
    },
}

# ── Review Sentiment Thresholds ───────────────────────────────────────────────
SENTIMENT_POSITIVE_THRESHOLD = 0.6   # score > 0.6 → positive sentiment
SENTIMENT_NEGATIVE_THRESHOLD = 0.4   # score < 0.4 → negative sentiment

SENTIMENT_LABELS = {
    (0.7, 1.0): "Very Positive ⭐⭐⭐",
    (0.5, 0.7): "Positive ✅",
    (0.3, 0.5): "Mixed ⚠️",
    (0.0, 0.3): "Negative ❌",
}

# ── Sentiment Impact on Viral Score ──────────────────────────────────────────
# Positive reviews boost viral score slightly, negative reviews reduce it
SENTIMENT_VIRAL_IMPACT = 0.10
