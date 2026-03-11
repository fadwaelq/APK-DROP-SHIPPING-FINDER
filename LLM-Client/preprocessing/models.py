# preprocessing/models.py
# ─────────────────────────────────────────────────────────────────────────────
# Input and output data models for the preprocessing layer.
# ─────────────────────────────────────────────────────────────────────────────

from dataclasses import dataclass, field, asdict
from typing import Optional, List, Tuple
import json


# ─────────────────────────────────────────────────────────────────────────────
# RAW DOM INPUT — exactly what the mobile team sends
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class RawDOMData:
    """
    Raw data extracted from the product page DOM by the mobile team.
    All fields are optional — DOM extraction may fail on any field.
    All values are raw strings exactly as found in the DOM.
    """
    image_url:     Optional[str] = None   # first product image URL
    description:   Optional[str] = None   # raw product description text
    price:         Optional[str] = None   # e.g. "US $4.50", "4,50 €", "$4.50"
    shipping:      Optional[str] = None   # e.g. "Free shipping", "$2.00", "€1.99"
    order_count:   Optional[str] = None   # e.g. "10,000+ sold", "10k+ orders"
    rating:        Optional[str] = None   # e.g. "4.7", "4.7 out of 5", "4.7/5"
    product_title: Optional[str] = None   # raw product title from page

    @classmethod
    def from_dict(cls, d: dict) -> "RawDOMData":
        return cls(
            image_url     = d.get("image_url"),
            description   = d.get("description"),
            price         = d.get("price"),
            shipping      = d.get("shipping"),
            order_count   = d.get("order_count"),
            rating        = d.get("rating"),
            product_title = d.get("product_title"),
        )


# ─────────────────────────────────────────────────────────────────────────────
# CLEAN OUTPUT — what your ML pipeline receives
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class CleanProductData:
    """
    Cleaned and validated product data ready for the ML pipeline.

    image_url     → Layer 1 (Vision AI)
    description   → Layer 2 (Text Extraction)
    price +
    shipping +
    order_proxy +
    rating        → Layer 3 (Scoring Engine)
    """
    # Layer 1 input
    image_url:      Optional[str]   = None

    # Layer 2 input
    description:    str             = ""

    # Layer 3 inputs
    supplier_price: Optional[float] = None    # None → user must enter manually
    shipping_cost:  float           = 0.0
    order_proxy:    int             = 0
    rating:         float           = 0.0

    # Metadata
    product_title:  str             = ""
    missing_fields: List[str]       = field(default_factory=list)
    warnings:       List[str]       = field(default_factory=list)

    @property
    def needs_manual_price(self) -> bool:
        """True if supplier price could not be extracted — user must enter it."""
        return self.supplier_price is None

    @property
    def has_image(self) -> bool:
        return self.image_url is not None and len(self.image_url) > 0

    @property
    def has_description(self) -> bool:
        return len(self.description.split()) >= 3

    @property
    def description_source(self) -> str:
        """Where the text input for Layer 2 came from."""
        if len(self.description.split()) >= 10:
            return "full_description"
        if self.product_title:
            return "title_fallback"
        return "none"

    def text_for_layer2(self) -> str:
        """
        Returns the best available text for Layer 2.
        Falls back to product_title if description is empty or too short.
        This handles listing-level web mining where only title is available.
        """
        if len(self.description.split()) >= 5:
            return self.description
        if self.product_title:
            return self.product_title
        return ""

    @property
    def is_complete(self) -> bool:
        """True if all fields needed for full pipeline are available."""
        return (
            self.has_image and
            self.has_description and
            self.supplier_price is not None
        )

    def to_layer1_input(self) -> dict:
        """Format for Layer 1 inference."""
        return {"image_url": self.image_url}

    def to_layer2_input(self) -> dict:
        """
        Format for Layer 2 inference.
        Uses text_for_layer2() which falls back to product_title
        when description is empty (listing-level web mining mode).
        """
        return {
            "text":              self.text_for_layer2(),
            "description_source": self.description_source,
        }

    def to_layer3_input(self, layer1_output: dict, layer2_output: dict) -> dict:
        """Format for Layer 3 scoring engine."""
        return {
            "layer1":     layer1_output,
            "layer2":     layer2_output,
            "user_input": {
                "supplier_price":  self.supplier_price  or 0.0,
                "shipping_cost":   self.shipping_cost,
                "ad_budget_daily": 0.0,   # user sets this separately
            },
        }

    def to_dict(self) -> dict:
        return asdict(self)

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), indent=2)
