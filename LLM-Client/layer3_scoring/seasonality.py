# layer3_scoring/seasonality.py
# ─────────────────────────────────────────────────────────────────────────────
# Seasonality Scorer
# ─────────────────────────────────────────────────────────────────────────────
# Provides a seasonality multiplier and timing advice for a product category
# based on the current month.
#
# No model needed — rule-based lookup table.
# Data is baked in from real e-commerce seasonal patterns.
#
# Usage:
#   from seasonality import SeasonalityScorer
#   result = SeasonalityScorer().score("fitness_outdoor", month=1)
#   print(result.score)        # 0.85
#   print(result.label)        # "Peak Season 🔥"
#   print(result.advice)       # "January is the best month to sell fitness..."
# ─────────────────────────────────────────────────────────────────────────────

from __future__ import annotations
import datetime
from dataclasses import dataclass
from typing import Dict, Tuple

from constants import SEASONALITY_TABLE, SEASONALITY_LABELS, SEASONALITY_ADVICE


# ─────────────────────────────────────────────────────────────────────────────
# OUTPUT MODEL
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class SeasonalityResult:
    """
    Seasonality scoring result for one category + month combination.

    score   : 0.0 to 1.0 — how good this month is for selling this category
    label   : human-readable tier label
    advice  : one-sentence timing recommendation for the user
    month   : the month used for scoring (1-12)
    peak_months : list of best months for this category
    """
    score:       float
    label:       str
    advice:      str
    month:       int
    peak_months: list


# ─────────────────────────────────────────────────────────────────────────────
# SEASONALITY SCORER
# ─────────────────────────────────────────────────────────────────────────────

class SeasonalityScorer:
    """
    Rule-based seasonality scorer.

    Lookup: category + month → score (0.0 to 1.0)

    Score interpretation:
        0.8 – 1.0  → Peak season   — best time to launch / advertise
        0.6 – 0.8  → Good season   — solid performance expected
        0.4 – 0.6  → Average       — neutral, proceed normally
        0.0 – 0.4  → Off season    — consider delaying launch

    The score is used by Layer 3 as a multiplier on the viral_score.
    """

    def score(
        self,
        category: str,
        month: int = 0,
    ) -> SeasonalityResult:
        """
        Score a product category for the given month.

        Args:
            category : one of the 6 product categories
            month    : 1-12. If 0 (default), uses the current real month.

        Returns:
            SeasonalityResult
        """
        if month == 0:
            month = datetime.date.today().month

        month = max(1, min(12, month))   # clamp to valid range

        # Look up monthly scores for this category
        monthly_scores: Dict[int, float] = SEASONALITY_TABLE.get(
            category,
            SEASONALITY_TABLE["gadget"],   # fallback to gadget if unknown
        )

        raw_score = monthly_scores.get(month, 0.5)

        # Determine label
        label = self._get_label(raw_score)

        # Determine peak months for this category
        peak_months = [
            m for m, s in monthly_scores.items() if s >= 0.75
        ]

        # Build advice
        advice = self._get_advice(category, month, raw_score, peak_months)

        return SeasonalityResult(
            score       = round(raw_score, 2),
            label       = label,
            advice      = advice,
            month       = month,
            peak_months = sorted(peak_months),
        )

    @staticmethod
    def _get_label(score: float) -> str:
        for (lo, hi), label in SEASONALITY_LABELS.items():
            if lo <= score <= hi:
                return label
        return "Average ☁️"

    @staticmethod
    def _get_advice(
        category: str,
        month: int,
        score: float,
        peak_months: list,
    ) -> str:
        """
        Returns a one-sentence timing recommendation.
        Uses pre-written advice strings from constants, filled with context.
        """
        template = SEASONALITY_ADVICE.get(category, {}).get(
            _month_bucket(score),
            "Timing is average for this category this month."
        )

        # Fill in month names if template uses them
        month_name     = _month_name(month)
        peak_name      = _month_name(peak_months[0]) if peak_months else "later"

        return template.format(
            month     = month_name,
            peak      = peak_name,
        )


# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

def _month_bucket(score: float) -> str:
    """Map score to advice bucket key."""
    if score >= 0.8:
        return "peak"
    if score >= 0.6:
        return "good"
    if score >= 0.4:
        return "average"
    return "off"


def _month_name(month: int) -> str:
    months = [
        "", "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    return months[month] if 1 <= month <= 12 else "Unknown"


# ─────────────────────────────────────────────────────────────────────────────
# QUICK TEST
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    scorer = SeasonalityScorer()

    test_cases = [
        ("fitness_outdoor",     1),   # January — peak
        ("gadget",             11),   # November — peak (Black Friday)
        ("beauty",              2),   # February — good (Valentine's)
        ("home_kitchen",        6),   # June — average
        ("fashion_accessories", 9),   # September — good (back to school)
        ("pet_kids",           12),   # December — peak (Christmas)
    ]

    print("SeasonalityScorer — Quick Test")
    print("=" * 60)
    for category, month in test_cases:
        result = scorer.score(category, month)
        print(f"\n{category} | {_month_name(month)}")
        print(f"  Score : {result.score}  |  {result.label}")
        print(f"  Advice: {result.advice}")
        print(f"  Peaks : {[_month_name(m) for m in result.peak_months]}")
