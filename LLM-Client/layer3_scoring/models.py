# layer3_scoring/models.py
# ─────────────────────────────────────────────────────────────────────────────
# Input and output data models for Layer 3.
# Layer 1 and Layer 2 outputs are passed in as dicts matching these schemas.
# ─────────────────────────────────────────────────────────────────────────────

from dataclasses import dataclass, field, asdict
from typing import List, Optional
import json

# Sentinel used as default when no review data is available (SonarQube S1192)
NO_REVIEWS_LABEL: str = "No Reviews"


# ─────────────────────────────────────────────────────────────────────────────
# LAYER 1 OUTPUT — Vision AI result
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class Layer1Output:
    """
    Output from the Vision AI model (Layer 1).
    All fields are required — populated by MobileNetV3 inference.
    """
    category:      str    # gadget | beauty | home_kitchen | fashion_accessories | pet_kids | fitness_outdoor
    wow_score:     float  # 0.0 – 1.0
    tiktokability: float  # 0.0 – 1.0
    market_type:   str    # mass | niche | premium

    @classmethod
    def from_dict(cls, d: dict) -> "Layer1Output":
        return cls(
            category      = d["category"],
            wow_score     = float(d["wow_score"]),
            tiktokability = float(d["tiktokability"]),
            market_type   = d["market_type"],
        )


# ─────────────────────────────────────────────────────────────────────────────
# LAYER 2 OUTPUT — Text Extraction result
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class Layer2Output:
    """
    Output from the Text Extraction model (Layer 2).
    All fields are required — populated by DistilBERT inference + post-processor.
    """
    product_name:     str
    key_features:     List[str]
    target_audience:  List[str]
    problem_solved:   str
    main_benefit:     str
    usp:              str
    main_promise:     str
    marketing_angle:  str   # problem_solution | transformation | social_proof |
                            # curiosity | convenience | identity | value
    audience_size:    str   # mass | niche

    # Review sentiment — populated by ReviewAnalyzer if reviews available
    review_sentiment_score: float     = 0.5
    review_sentiment_label: str       = NO_REVIEWS_LABEL
    customer_praise:        List[str] = field(default_factory=list)
    customer_complaints:    List[str] = field(default_factory=list)
    review_count:           int       = 0

    @classmethod
    def from_dict(cls, d: dict) -> "Layer2Output":
        return cls(
            product_name           = d.get("product_name",           ""),
            key_features           = d.get("key_features",           []),
            target_audience        = d.get("target_audience",        []),
            problem_solved         = d.get("problem_solved",         ""),
            main_benefit           = d.get("main_benefit",           ""),
            usp                    = d.get("usp",                    ""),
            main_promise           = d.get("main_promise",           ""),
            marketing_angle        = d.get("marketing_angle",        "convenience"),
            audience_size          = d.get("audience_size",          "mass"),
            review_sentiment_score = float(d.get("review_sentiment_score", 0.5)),
            review_sentiment_label = d.get("review_sentiment_label", NO_REVIEWS_LABEL),
            customer_praise        = d.get("customer_praise",        []),
            customer_complaints    = d.get("customer_complaints",    []),
            review_count           = int(d.get("review_count",       0)),
        )


# ─────────────────────────────────────────────────────────────────────────────
# USER INPUT — Provided directly by the user in the app
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class UserInput:
    """
    Fields the user enters manually in the app.
    Used by the margin calculator.
    """
    supplier_price:   float   # cost to buy from supplier ($)
    shipping_cost:    float   # shipping cost to customer ($)
    ad_budget_daily:  float   # daily ad spend ($)

    @classmethod
    def from_dict(cls, d: dict) -> "UserInput":
        return cls(
            supplier_price  = float(d.get("supplier_price",  0.0)),
            shipping_cost   = float(d.get("shipping_cost",   0.0)),
            ad_budget_daily = float(d.get("ad_budget_daily", 0.0)),
        )


# ─────────────────────────────────────────────────────────────────────────────
# SCORING INPUT — Full input to Layer 3
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class ScoringInput:
    """
    Complete input to the Layer 3 scoring engine.
    Aggregates outputs from Layer 1, Layer 2, user input,
    and optional signals from the weekly server sync.
    """
    layer1:      Layer1Output
    layer2:      Layer2Output
    user_input:  UserInput
    trend_score: float = 0.5   # 0.0–1.0, from weekly sync (default neutral)

    @classmethod
    def from_dict(cls, d: dict) -> "ScoringInput":
        return cls(
            layer1      = Layer1Output.from_dict(d["layer1"]),
            layer2      = Layer2Output.from_dict(d["layer2"]),
            user_input  = UserInput.from_dict(d["user_input"]),
            trend_score = float(d.get("trend_score", 0.5)),
        )


# ─────────────────────────────────────────────────────────────────────────────
# SCORING OUTPUT — Layer 3 result
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class MarginResult:
    """Detailed margin calculation breakdown."""
    supplier_price:    float
    shipping_cost:     float
    total_cost:        float
    recommended_price: float
    gross_margin:      float   # (price - cost) / price
    gross_margin_pct:  str     # "62.3%"
    profit_per_unit:   float
    roas_target:       float
    margin_label:      str     # High | Medium | Low


@dataclass
class ScoringOutput:
    """
    Complete output from Layer 3.
    Passed to Layer 4 (Marketing Generator) and displayed in the app.
    """
    # Core scores
    viral_score:        float   # 0.0 – 10.0
    viral_label:        str     # "🔥 Viral Potential" | "⚡ Strong" | etc.
    competition_risk:   str     # High | Medium | Low
    margin_potential:   str     # High | Medium | Low

    # Margin detail
    margin:             MarginResult

    # Pass-through for Layer 4
    product_name:       str
    usp:                str
    main_promise:       str
    marketing_angle:    str
    key_features:       List[str]
    category:           str
    market_type:        str

    # Seasonality
    seasonality_score:  float = 0.5
    seasonality_label:  str   = "Average ☁️"
    seasonality_advice: str   = ""
    peak_months:        List[int] = field(default_factory=list)

    # Review sentiment pass-through
    review_sentiment_score: float     = 0.5
    review_sentiment_label: str       = NO_REVIEWS_LABEL
    customer_praise:        List[str] = field(default_factory=list)
    customer_complaints:    List[str] = field(default_factory=list)
    review_count:           int       = 0

    def to_dict(self) -> dict:
        return asdict(self)

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), indent=2)

    def summary(self) -> str:
        """Human-readable one-liner for logging."""
        return (
            f"{self.product_name} | "
            f"Viral: {self.viral_score}/10 ({self.viral_label}) | "
            f"Competition: {self.competition_risk} | "
            f"Margin: {self.margin_potential} ({self.margin.gross_margin_pct}) | "
            f"Season: {self.seasonality_label} | "
            f"Reviews: {self.review_sentiment_label}"
        )
