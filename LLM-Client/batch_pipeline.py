# batch_pipeline.py
# ─────────────────────────────────────────────────────────────────────────────
# Batch Pipeline — Multi-product scoring from a single page URL
# ─────────────────────────────────────────────────────────────────────────────
#
# The backend agent browses a URL (AliExpress category / search page),
# extracts all visible products via web mining, and sends the ML team
# a list of product dicts. This module processes all of them and returns
# a ranked list of scored results.
#
# Architecture:
#   Backend Agent → list of product dicts
#   → BatchPipeline.run()
#       → For each product: Layer 0 → Layer 1 → Layer 2 → Layer 3
#   → RankingModule.rank()
#       → Winners / Worth Watching / Skip
#   → Layer 4 runs ON DEMAND only (user taps a product)
#
# Usage:
#   from batch_pipeline import BatchPipeline
#
#   payload = {
#       "source_url": "https://aliexpress.com/category/...",
#       "page_type":  "category",
#       "products": [
#           {"product_title": "Smart Massager", "price": "US $12.50", ...},
#           {"product_title": "LED Mirror", "price": "US $4.50", ...},
#       ]
#   }
#   result = BatchPipeline().run(payload)
#   print(result.winners)        # top scored products
#   print(result.worth_watching) # decent but not top tier
#   print(result.skipped_count)  # how many were filtered out
# ─────────────────────────────────────────────────────────────────────────────

from __future__ import annotations
import sys
import os
import json
import time
from dataclasses import dataclass, field, asdict
from typing import List, Optional, Dict, Any

# ── Path setup ────────────────────────────────────────────────────────────────
# Note: do NOT add layer3_scoring to sys.path here — it is invoked via subprocess
# to avoid module name conflicts (both directories have a models.py).
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "preprocessing"))

from models import RawDOMData, CleanProductData                       # preprocessing


# ─────────────────────────────────────────────────────────────────────────────
# PRODUCT RESULT — one product's full pipeline output
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class ProductResult:
    """
    Full scoring result for one product from the batch.

    rank              : position in final ranked list (1 = best)
    tier              : winner | worth_watching | skip
    product_title     : cleaned product title
    image_url         : product image URL
    viral_score       : 0.0 to 10.0
    viral_label       : human-readable viral label
    competition_risk  : Low | Medium | High
    margin_potential  : Low | Medium | High
    recommended_price : suggested sell price
    profit_per_unit   : estimated profit
    seasonality_label : Peak Season | Good | Average | Off Season
    seasonality_advice: timing recommendation
    description_source: full_description | title_fallback | none
    error             : error message if pipeline failed for this product
    raw_input         : original dict from backend agent (for debugging)
    """
    rank:               int
    tier:               str         # winner | worth_watching | skip
    product_title:      str
    image_url:          Optional[str]
    viral_score:        float
    viral_label:        str
    competition_risk:   str
    margin_potential:   str
    recommended_price:  float
    profit_per_unit:    float
    seasonality_label:  str
    seasonality_advice: str
    description_source: str
    error:              Optional[str] = None
    raw_input:          Dict[str, Any] = field(default_factory=dict)

    @property
    def is_winner(self) -> bool:
        return self.tier == "winner"

    @property
    def has_error(self) -> bool:
        return self.error is not None

    def to_dict(self) -> dict:
        return asdict(self)

    def summary(self) -> str:
        return (
            f"[{self.tier.upper():^13}] #{self.rank:02d} | "
            f"Viral: {self.viral_score:4.1f}/10 | "
            f"Comp: {self.competition_risk:<6} | "
            f"Margin: {self.margin_potential:<6} | "
            f"Text: {self.description_source:<18} | "
            f"{self.product_title[:45]}"
        )


# ─────────────────────────────────────────────────────────────────────────────
# BATCH RESULT — full output of BatchPipeline.run()
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class BatchResult:
    """
    Complete batch processing result.

    winners        : top products (viral_score >= 7.0, not high competition)
    worth_watching : decent products (viral_score >= 4.5)
    skipped        : weak or filtered products
    errors         : products that failed pipeline processing
    total_input    : total products received from backend agent
    processing_ms  : total time to process the batch
    source_url     : original URL the backend agent scraped
    page_type      : category | search | store
    """
    winners:        List[ProductResult]
    worth_watching: List[ProductResult]
    skipped:        List[ProductResult]
    errors:         List[ProductResult]
    total_input:    int
    processing_ms:  int
    source_url:     str
    page_type:      str

    @property
    def skipped_count(self) -> int:
        return len(self.skipped)

    @property
    def error_count(self) -> int:
        return len(self.errors)

    @property
    def success_count(self) -> int:
        return len(self.winners) + len(self.worth_watching) + len(self.skipped)

    def summary(self) -> str:
        return (
            f"BatchResult | {self.source_url[:60]} | "
            f"Input: {self.total_input} | "
            f"Winners: {len(self.winners)} | "
            f"WatchList: {len(self.worth_watching)} | "
            f"Skipped: {self.skipped_count} | "
            f"Errors: {self.error_count} | "
            f"{self.processing_ms}ms"
        )

    def to_dict(self) -> dict:
        return {
            "winners":        [p.to_dict() for p in self.winners],
            "worth_watching": [p.to_dict() for p in self.worth_watching],
            "skipped":        [p.to_dict() for p in self.skipped],
            "errors":         [p.to_dict() for p in self.errors],
            "total_input":    self.total_input,
            "processing_ms":  self.processing_ms,
            "source_url":     self.source_url,
            "page_type":      self.page_type,
        }


# ─────────────────────────────────────────────────────────────────────────────
# RANKING MODULE
# ─────────────────────────────────────────────────────────────────────────────

# Thresholds
WINNER_VIRAL_MIN      = 7.0    # viral_score >= 7.0 to be a winner
WATCHLIST_VIRAL_MIN   = 4.5    # viral_score >= 4.5 to be worth watching
WINNER_MAX_COUNT      = 5      # show at most 5 winners
WATCHLIST_MAX_COUNT   = 8      # show at most 8 worth watching

def _tier(viral_score: float, competition_risk: str, margin_potential: str) -> str:
    """
    Classify a product into winner / worth_watching / skip.

    Rules:
    - skip  : High competition AND Low margin (not worth selling)
    - skip  : viral_score < WATCHLIST_VIRAL_MIN
    - winner: viral_score >= WINNER_VIRAL_MIN AND NOT (High comp + Low margin)
    - worth_watching: everything else above WATCHLIST_VIRAL_MIN
    """
    if competition_risk == "High" and margin_potential == "Low":
        return "skip"
    if viral_score < WATCHLIST_VIRAL_MIN:
        return "skip"
    if viral_score >= WINNER_VIRAL_MIN:
        return "winner"
    return "worth_watching"


def rank_results(scored: List[dict]) -> tuple:
    """
    Sort and classify a list of scored product dicts.
    Returns (winners, worth_watching, skipped) — each a list of ProductResult.
    """
    # Sort by viral_score descending
    scored_sorted = sorted(scored, key=lambda x: x.get("viral_score", 0.0), reverse=True)

    winners        = []
    worth_watching = []
    skipped        = []
    rank           = 0

    for item in scored_sorted:
        viral        = item.get("viral_score", 0.0)
        comp         = item.get("competition_risk", "High")
        margin       = item.get("margin_potential", "Low")
        tier         = _tier(viral, comp, margin)

        # Cap winners and watchlist
        if tier == "winner" and len(winners) >= WINNER_MAX_COUNT:
            tier = "worth_watching"
        if tier == "worth_watching" and len(worth_watching) >= WATCHLIST_MAX_COUNT:
            tier = "skip"

        rank += 1 if tier != "skip" else 0

        result = ProductResult(
            rank               = rank if tier != "skip" else 0,
            tier               = tier,
            product_title      = item.get("product_title", ""),
            image_url          = item.get("image_url"),
            viral_score        = viral,
            viral_label        = item.get("viral_label", ""),
            competition_risk   = comp,
            margin_potential   = margin,
            recommended_price  = item.get("margin", {}).get("recommended_price", 0.0),
            profit_per_unit    = item.get("margin", {}).get("profit_per_unit", 0.0),
            seasonality_label  = item.get("seasonality_label", ""),
            seasonality_advice = item.get("seasonality_advice", ""),
            description_source = item.get("description_source", "none"),
            raw_input          = item.get("_raw_input", {}),
        )

        if tier == "winner":
            winners.append(result)
        elif tier == "worth_watching":
            worth_watching.append(result)
        else:
            skipped.append(result)

    return winners, worth_watching, skipped


# ─────────────────────────────────────────────────────────────────────────────
# MOCK LAYER FUNCTIONS (replaced by real TFLite inference after training)
# ─────────────────────────────────────────────────────────────────────────────

import re as _re

def _mock_layer1(image_url: str) -> dict:
    """Simulate Layer 1 output — deterministic from URL hash."""
    seed = sum(ord(c) for c in (image_url or "")) % 100
    categories = ["gadget","beauty","home_kitchen","fashion_accessories","pet_kids","fitness_outdoor"]
    return {
        "category":      categories[seed % len(categories)],
        "wow_score":     round(0.45 + (seed % 50) / 100, 2),
        "tiktokability": round(0.40 + (seed % 55) / 100, 2),
        "market_type":   ["mass","niche","premium"][seed % 3],
    }

def _mock_layer2(text: str, description_source: str) -> dict:
    """Simulate Layer 2 output from short title or full description."""
    dl    = text.lower()
    words = text.split()

    # Feature extraction
    features = []
    for m in _re.finditer(r"\d+[x°%]?\s*\w+(?:\s+\w+)?", text):
        feat = m.group().strip()
        if len(feat.split()) <= 4 and feat not in features:
            features.append(feat)
    for kw in ["wireless","portable","waterproof","usb","rechargeable","smart","electric","led","auto"]:
        if kw in dl and kw not in features:
            features.append(kw)
    features = features[:4]

    usp = features[0] if features else (words[0] if words else "product")

    if any(w in dl for w in ["pain","douleur","stop","fix","solve","relief"]):
        angle = "problem_solution"
    elif any(w in dl for w in ["transform","glow","upgrade","smart"]):
        angle = "transformation"
    elif any(w in dl for w in ["instant","easy","auto","wireless","portable"]):
        angle = "convenience"
    else:
        angle = "value"

    audience_size = "niche" if any(w in dl for w in ["pro","professional","athlete","serious"]) else "mass"

    # Weaker confidence when title-only
    confidence_note = "low_confidence_title_only" if description_source == "title_fallback" else "normal"

    return {
        "product_name":          " ".join(words[:5]) if len(words) >= 5 else text,
        "key_features":          features,
        "target_audience":       [],
        "problem_solved":        "",
        "main_benefit":          usp,
        "usp":                   usp,
        "main_promise":          f"Get {usp}",
        "marketing_angle":       angle,
        "audience_size":         audience_size,
        "review_sentiment_score": 0.5,
        "review_sentiment_label": "No Reviews",
        "customer_praise":        [],
        "customer_complaints":    [],
        "review_count":           0,
        "_confidence":            confidence_note,
    }


# ─────────────────────────────────────────────────────────────────────────────
# SINGLE PRODUCT PIPELINE
# ─────────────────────────────────────────────────────────────────────────────

def _run_single(raw_dict: dict) -> dict:
    """
    Run the full pipeline for one product dict.
    Returns a flat dict with all scoring fields + metadata.
    Raises on unrecoverable errors — caller handles per-product exceptions.
    """
    import subprocess, sys

    # ── Layer 0 — Preprocessing ───────────────────────────────────────────
    preproc_script = os.path.join(os.path.dirname(__file__), "preprocessing")
    cmd = [
        sys.executable, "-c",
        f"""
import sys; sys.path.insert(0, '{preproc_script}')
import json
from models import RawDOMData
from signal_parser import parse_price, parse_shipping, parse_order_count, parse_rating, validate_image_url
from text_cleaner import clean_description, detect_language
from constants import DEFAULT_LANGUAGE

raw  = RawDOMData.from_dict({json.dumps(raw_dict)})
img, img_warn    = validate_image_url(raw.image_url)
price, price_w   = parse_price(raw.price)
ship, ship_w     = parse_shipping(raw.shipping)
orders, ord_w    = parse_order_count(raw.order_count)
rating, rat_w    = parse_rating(raw.rating)

# Text: description if available, else title
text_src = raw.description or raw.product_title or ""
has_full_desc = bool(raw.description and len((raw.description or "").split()) >= 5)
desc, desc_w = clean_description(text_src)

import dataclasses
from models import CleanProductData
clean = CleanProductData(
    image_url      = img,
    description    = desc if has_full_desc else "",
    supplier_price = price,
    shipping_cost  = ship,
    order_proxy    = orders,
    rating         = rating,
    product_title  = (raw.product_title or "").strip(),
    warnings       = [w for w in [img_warn, price_w, ship_w, ord_w, rat_w] + desc_w if w],
)
print(json.dumps(dataclasses.asdict(clean)))
"""
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
    if proc.returncode != 0:
        raise RuntimeError(f"Preprocessing failed: {proc.stderr.strip()[:200]}")
    clean = json.loads(proc.stdout.strip())

    # ── Determine text source ─────────────────────────────────────────────
    desc_text   = clean.get("description", "")
    title_text  = clean.get("product_title", "")
    if len(desc_text.split()) >= 5:
        layer2_text = desc_text
        desc_source = "full_description"
    elif title_text:
        layer2_text = title_text
        desc_source = "title_fallback"
    else:
        layer2_text = ""
        desc_source = "none"

    # ── Layer 1 — Vision AI (mock) ────────────────────────────────────────
    l1 = _mock_layer1(clean.get("image_url") or "")

    # ── Layer 2 — Text Extraction (mock) ─────────────────────────────────
    l2 = _mock_layer2(layer2_text, desc_source)

    # ── Layer 3 — Scoring Engine ──────────────────────────────────────────
    layer3_dir = os.path.join(os.path.dirname(__file__), "layer3_scoring")
    cmd3 = [
        sys.executable, "-c",
        f"""
import sys; sys.path.insert(0, '{layer3_dir}')
import json
from scorer import ScoringEngine
result = ScoringEngine().score({{
    "layer1":      {json.dumps(l1)},
    "layer2":      {json.dumps(l2)},
    "user_input":  {{
        "supplier_price":  {clean.get("supplier_price") or 5.0},
        "shipping_cost":   {clean.get("shipping_cost", 0.0)},
        "ad_budget_daily": 20.0
    }},
    "trend_score": 0.5,
}})
print(json.dumps(result.to_dict()))
"""
    ]
    proc3 = subprocess.run(cmd3, capture_output=True, text=True, timeout=10)
    if proc3.returncode != 0:
        raise RuntimeError(f"Layer 3 failed: {proc3.stderr.strip()[:200]}")
    l3 = json.loads(proc3.stdout.strip())

    # ── Merge into flat result dict ───────────────────────────────────────
    return {
        **l3,
        "product_title":      clean.get("product_title", ""),
        "image_url":          clean.get("image_url"),
        "description_source": desc_source,
        "_raw_input":         raw_dict,
    }


# ─────────────────────────────────────────────────────────────────────────────
# BATCH PIPELINE — PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────

class BatchPipeline:
    """
    Processes a list of products from a single page URL.

    Input format (from backend agent):
    {
        "source_url": "https://aliexpress.com/category/...",
        "page_type":  "category | search | store",
        "products": [
            {
                "product_title": "Smart Neck Massager",
                "image_url":     "//cdn.alicdn.com/img/massager.jpg",
                "price":         "US $12.50",
                "shipping":      "Free shipping",
                "order_count":   "8,500+ sold",
                "rating":        "4.6 out of 5",
                "description":   ""          ← empty for listing-level mining
            },
            ...
        ]
    }

    Output: BatchResult with winners, worth_watching, skipped, errors.
    """

    MAX_PRODUCTS = 60   # AliExpress listing pages show up to 60 products

    def run(self, payload: dict) -> BatchResult:
        """
        Main entry point.

        Args:
            payload: dict with source_url, page_type, products list

        Returns:
            BatchResult
        """
        t_start     = time.time()
        source_url  = payload.get("source_url", "")
        page_type   = payload.get("page_type", "unknown")
        products    = payload.get("products", [])

        # Cap batch size
        if len(products) > self.MAX_PRODUCTS:
            products = products[:self.MAX_PRODUCTS]

        scored  = []
        errors  = []

        for i, raw_dict in enumerate(products):
            try:
                result = _run_single(raw_dict)
                scored.append(result)
            except Exception as e:
                # One bad product does not crash the batch
                title = raw_dict.get("product_title", f"product_{i+1}")
                errors.append(ProductResult(
                    rank               = 0,
                    tier               = "error",
                    product_title      = title,
                    image_url          = raw_dict.get("image_url"),
                    viral_score        = 0.0,
                    viral_label        = "",
                    competition_risk   = "Unknown",
                    margin_potential   = "Unknown",
                    recommended_price  = 0.0,
                    profit_per_unit    = 0.0,
                    seasonality_label  = "",
                    seasonality_advice = "",
                    description_source = "none",
                    error              = str(e),
                    raw_input          = raw_dict,
                ))

        # Rank results
        winners, worth_watching, skipped = rank_results(scored)

        processing_ms = int((time.time() - t_start) * 1000)

        return BatchResult(
            winners        = winners,
            worth_watching = worth_watching,
            skipped        = skipped,
            errors         = errors,
            total_input    = len(products),
            processing_ms  = processing_ms,
            source_url     = source_url,
            page_type      = page_type,
        )


# ─────────────────────────────────────────────────────────────────────────────
# TEST
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    payload = {
        "source_url": "https://aliexpress.com/category/consumer-electronics/massagers",
        "page_type":  "category",
        "products": [
            {   # Good product — title only (listing-level)
                "product_title": "Smart Electric Neck Massager Wireless Pulse Pain Relief",
                "image_url":     "//ae01.alicdn.com/kf/massager_pro.jpg",
                "price":         "US $12.50",
                "shipping":      "Free shipping",
                "order_count":   "8,500+ sold",
                "rating":        "4.6 out of 5",
                "description":   "",
            },
            {   # Great product — full description available
                "product_title": "Portable LED Makeup Mirror 10x Magnification",
                "image_url":     "//ae01.alicdn.com/kf/led_mirror.jpg",
                "price":         "US $4.50",
                "shipping":      "Free shipping",
                "order_count":   "10,000+ sold",
                "rating":        "4.7 out of 5",
                "description":   "Portable LED Makeup Mirror with 10x magnification. USB rechargeable. Perfect for travel. Never struggle with bad lighting again.",
            },
            {   # Average product
                "product_title": "Resistance Band Set 5 Levels Anti-Snap Workout",
                "image_url":     "//ae01.alicdn.com/kf/bands.jpg",
                "price":         "US $8.99",
                "shipping":      "Free shipping",
                "order_count":   "3,200+ sold",
                "rating":        "4.3 out of 5",
                "description":   "",
            },
            {   # Weak product — missing price
                "product_title": "Generic Phone Case Cover",
                "image_url":     "//ae01.alicdn.com/kf/case.jpg",
                "price":         "",
                "shipping":      "$1.99",
                "order_count":   "500+ sold",
                "rating":        "3.8 out of 5",
                "description":   "",
            },
            {   # Bad product — missing everything
                "product_title": "",
                "image_url":     "",
                "price":         "",
                "shipping":      "",
                "order_count":   "",
                "rating":        "",
                "description":   "",
            },
        ]
    }

    print("BatchPipeline — Test Run")
    print("=" * 80)
    pipeline = BatchPipeline()
    result   = pipeline.run(payload)

    print(f"\n{result.summary()}\n")

    if result.winners:
        print("🏆 WINNERS")
        for p in result.winners:
            print(f"  {p.summary()}")

    if result.worth_watching:
        print("\n👀 WORTH WATCHING")
        for p in result.worth_watching:
            print(f"  {p.summary()}")

    if result.skipped:
        print(f"\n❄️  SKIPPED ({result.skipped_count})")
        for p in result.skipped:
            print(f"  {p.summary()}")

    if result.errors:
        print(f"\n❌ ERRORS ({result.error_count})")
        for p in result.errors:
            print(f"  [{p.tier.upper()}] {p.product_title[:40]} — {p.error[:60]}")

    print(f"\n✅ Done in {result.processing_ms}ms")
