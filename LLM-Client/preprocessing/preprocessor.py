# preprocessing/preprocessor.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 0 — Main Preprocessor
# ─────────────────────────────────────────────────────────────────────────────
# The single entry point between the DOM extractor (mobile team)
# and your ML pipeline (Layers 1, 2, 3, 4).
#
# Usage:
#   from preprocessor import Preprocessor
#
#   result = Preprocessor().process({
#       "image_url":   "//ae01.alicdn.com/product.jpg",
#       "description": "Portable LED Makeup Mirror with 10x...",
#       "price":       "US $4.50",
#       "shipping":    "Free shipping",
#       "order_count": "10,000+ sold",
#       "rating":      "4.7 out of 5",
#   })
#
#   result.description      → clean text for Layer 2
#   result.supplier_price   → float for Layer 3 (or None → ask user)
#   result.image_url        → clean URL for Layer 1
#   result.needs_manual_price → True if price extraction failed
# ─────────────────────────────────────────────────────────────────────────────

from typing import Union

from models        import RawDOMData, CleanProductData
from text_cleaner  import clean_description
from signal_parser import (
    parse_price, parse_shipping,
    parse_order_count, parse_rating,
    validate_image_url,
)
from constants import FALLBACK


# ─────────────────────────────────────────────────────────────────────────────
# PREPROCESSOR
# ─────────────────────────────────────────────────────────────────────────────

class Preprocessor:
    """
    Cleans raw DOM data and returns structured CleanProductData.

    Flow:
        RawDOMData
            ↓
        image_url    → validate_image_url()
        description  → clean_description()
        price        → parse_price()
        shipping     → parse_shipping()
        order_count  → parse_order_count()
        rating       → parse_rating()
            ↓
        CleanProductData → Layer 1, 2, 3
    """

    def process(self, raw: Union[dict, RawDOMData]) -> CleanProductData:
        """
        Main entry point.

        Args:
            raw: dict from mobile team OR RawDOMData instance

        Returns:
            CleanProductData ready for ML pipeline
        """
        if isinstance(raw, dict):
            raw = RawDOMData.from_dict(raw)

        result   = CleanProductData()
        warnings = []
        missing  = []

        # ── Image URL ─────────────────────────────────────────────────────────
        clean_url, url_status = validate_image_url(raw.image_url)
        if clean_url:
            result.image_url = clean_url
        else:
            missing.append("image_url")
            warnings.append(f"Image URL invalid: {url_status}")

        # ── Description ───────────────────────────────────────────────────────
        clean_text, text_warnings = clean_description(raw.description)
        result.description = clean_text
        warnings.extend(text_warnings)
        if not result.has_description:
            missing.append("description")

        # ── Supplier Price ────────────────────────────────────────────────────
        price, price_status = parse_price(raw.price)
        if price is not None:
            result.supplier_price = price
            if price_status == "range_taken":
                warnings.append("Price range detected — lower bound used")
        else:
            result.supplier_price = None   # → user must enter manually
            missing.append("supplier_price")
            warnings.append(f"Price extraction failed ({price_status}) — manual entry required")

        # ── Shipping Cost ─────────────────────────────────────────────────────
        shipping, shipping_status = parse_shipping(raw.shipping)
        result.shipping_cost = shipping
        if "assumed_free" in shipping_status:
            warnings.append(f"Shipping cost not found — assumed free")

        # ── Order Count ───────────────────────────────────────────────────────
        order_count, order_status = parse_order_count(raw.order_count)
        result.order_proxy = order_count
        if order_status != "ok":
            warnings.append(f"Order count not found — trend signal unavailable")

        # ── Rating ────────────────────────────────────────────────────────────
        rating, rating_status = parse_rating(raw.rating)
        result.rating = rating
        if rating_status != "ok":
            warnings.append(f"Rating not found ({rating_status})")

        # ── Product Title ─────────────────────────────────────────────────────
        if raw.product_title:
            result.product_title = raw.product_title.strip()

        # ── Finalize ──────────────────────────────────────────────────────────
        result.missing_fields = missing
        result.warnings       = warnings

        return result

    def get_pipeline_status(self, data: CleanProductData) -> dict:
        """
        Returns which layers can run based on available data.
        Used by the mobile team to decide what to show the user.
        """
        return {
            "layer1_ready":    data.has_image,
            "layer2_ready":    data.has_description,
            "layer3_ready":    data.supplier_price is not None,
            "layer4_ready":    data.supplier_price is not None,
            "needs_manual":    data.missing_fields,
            "warnings":        data.warnings,
            "is_complete":     data.is_complete,
        }
