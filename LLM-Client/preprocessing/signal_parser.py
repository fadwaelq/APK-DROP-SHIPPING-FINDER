# preprocessing/signal_parser.py
# ─────────────────────────────────────────────────────────────────────────────
# Parses raw DOM strings into clean numeric values.
# Handles all messy formats from AliExpress, Amazon, Temu, Shopify.
# ─────────────────────────────────────────────────────────────────────────────

import re
from typing import Optional, Tuple

from constants import (
    CURRENCY_SYMBOLS,
    PRICE_MIN, PRICE_MAX,
    RATING_MIN, RATING_MAX,
)


# ─────────────────────────────────────────────────────────────────────────────
# PRICE PARSER
# ─────────────────────────────────────────────────────────────────────────────

def parse_price(raw: Optional[str]) -> Tuple[Optional[float], str]:
    """
    Parse supplier price from DOM string.

    Handles:
        "US $4.50"      → 4.50
        "$4.50"         → 4.50
        "4,50 €"        → 4.50
        "4.50 - 6.00"   → 4.50  (take lower bound of range)
        "4.50USD"       → 4.50
        "From $4.50"    → 4.50

    Returns:
        (price_float, status)
        status: "ok" | "range_taken" | "parse_failed" | "out_of_range" | "missing"
    """
    if not raw:
        return None, "missing"

    text = str(raw).strip()

    # Remove currency symbols and words
    for symbol in CURRENCY_SYMBOLS:
        text = text.replace(symbol, "")
    text = re.sub(r'(?i)(from|starting at|price:|approx\.?)', '', text)
    text = text.strip()

    # Truncate before any regex to prevent ReDoS on adversarial input
    text = text[:64]

    # Handle price ranges — take lower bound
    # Digit groups are length-bounded to eliminate polynomial backtracking (SonarQube S5852)
    range_match = re.search(r'(\d{1,6}[.,]\d{1,4})\s{0,4}[-\u2013]\s{0,4}(\d{1,6}[.,]\d{1,4})', text)
    if range_match:
        text   = range_match.group(1)
        status = "range_taken"
    else:
        status = "ok"

    # Normalize decimal separator (European format: 4,50 → 4.50)
    # Only if comma is used as decimal (exactly 2 digits after comma at end)
    text = re.sub(r',(\d{2})$', r'.\1', text)
    text = text.replace(',', '')   # remove thousands separators

    price_match = re.search(r'\d+\.?\d*', text)
    if not price_match:
        return None, "parse_failed"
    try:
        price = float(price_match.group())
    except ValueError:
        return None, "parse_failed"

    if not (PRICE_MIN <= price <= PRICE_MAX):
        return None, "out_of_range"

    return round(price, 2), status


# ─────────────────────────────────────────────────────────────────────────────
# SHIPPING PARSER
# ─────────────────────────────────────────────────────────────────────────────

def parse_shipping(raw: Optional[str]) -> Tuple[float, str]:
    """
    Parse shipping cost from DOM string.

    Handles:
        "Free shipping"    → 0.0
        "FREE"             → 0.0
        "$2.00 shipping"   → 2.00
        "Shipping: $1.99"  → 1.99
        "+$2.00"           → 2.00

    Returns:
        (shipping_float, status)
    """
    if not raw:
        return 0.0, "missing_assumed_free"

    text = str(raw).lower().strip()

    if any(word in text for word in ["free", "gratuit", "gratis", "livraison gratuite"]):
        return 0.0, "free"

    # Try to extract a number
    for symbol in CURRENCY_SYMBOLS:
        text = text.replace(symbol.lower(), "")
    text = re.sub(r'(?i)(shipping|livraison|envío|spedizione|versand)', '', text)
    text = text.replace('+', '').strip()

    shipping_match = re.search(r'\d+\.?\d*', text)
    if not shipping_match:
        return 0.0, "parse_failed_assumed_free"
    try:
        shipping = float(shipping_match.group())
        return round(shipping, 2), "ok"
    except ValueError:
        return 0.0, "parse_failed_assumed_free"


# ─────────────────────────────────────────────────────────────────────────────
# ORDER COUNT PARSER
# ─────────────────────────────────────────────────────────────────────────────

def parse_order_count(raw: Optional[str]) -> Tuple[int, str]:
    """
    Parse order/sales count from DOM string.

    Handles:
        "10,000+ sold"    → 10000
        "10k+ orders"     → 10000
        "1.5m sold"       → 1500000
        "10000"           → 10000
        "500 orders"      → 500
        ">10000"          → 10000

    Returns:
        (order_count_int, status)
    """
    if not raw:
        return 0, "missing"

    text = str(raw).lower()
    text = re.sub(r'[,\+\>\s]', '', text)
    text = re.sub(r'(sold|orders?|vendus?|verkauft|vendidos?)', '', text)
    text = text.strip()

    try:
        if text.endswith('m'):
            return int(float(text[:-1]) * 1_000_000), "ok"
        if text.endswith('k'):
            return int(float(text[:-1]) * 1_000), "ok"
        return int(float(text)), "ok"
    except ValueError:
        return 0, "parse_failed"


# ─────────────────────────────────────────────────────────────────────────────
# RATING PARSER
# ─────────────────────────────────────────────────────────────────────────────

def parse_rating(raw: Optional[str]) -> Tuple[float, str]:
    """
    Parse product rating from DOM string.

    Handles:
        "4.7"              → 4.7
        "4.7 out of 5"    → 4.7
        "4.7/5"           → 4.7
        "4,7"             → 4.7   (European decimal)
        "★★★★☆"          → 4.0   (star symbols)
        "93%"             → 4.65  (percentage → 5-star scale)

    Returns:
        (rating_float, status)
    """
    if not raw:
        return 0.0, "missing"

    text = str(raw).strip()

    # Star symbol counting
    if '★' in text or '☆' in text:
        filled = text.count('★')
        return min(float(filled), 5.0), "stars_counted"

    # Percentage → 5-star scale
    # Digit groups are length-bounded to prevent polynomial backtracking (SonarQube S5852)
    text = text[:32]
    pct_match = re.search(r'(\d{1,3}(?:\.\d{1,2})?)\s{0,4}%', text)
    if pct_match:
        pct    = float(pct_match.group(1))
        rating = round((pct / 100) * 5, 1)
        return min(rating, 5.0), "percentage_converted"

    # Strip "out of 5", "/5" etc.
    text = re.sub(r'(?i)(out\s+of|von|sur|de|\/)\s*5', '', text)
    tokens = text.split()
    if not tokens:
        return 0.0, "parse_failed"
    text = tokens[0]

    # European decimal comma
    text = text.replace(',', '.')

    try:
        rating = float(text)
        if not (RATING_MIN <= rating <= RATING_MAX):
            return 0.0, "out_of_range"
        return round(rating, 1), "ok"
    except ValueError:
        return 0.0, "parse_failed"


# ─────────────────────────────────────────────────────────────────────────────
# IMAGE URL VALIDATOR
# ─────────────────────────────────────────────────────────────────────────────

def validate_image_url(url: Optional[str]) -> Tuple[Optional[str], str]:
    """
    Validate and clean an image URL from the DOM.

    Handles:
        - Protocol-relative URLs (//ae01.alicdn.com/...) → add https:
        - Tracking params → strip query string
        - Empty or None → return None

    Returns:
        (clean_url, status)
    """
    if not url or not url.strip():
        return None, "missing"

    url = url.strip()

    # Protocol-relative URL
    if url.startswith("//"):
        url = "https:" + url

    # Must be a real URL — http:// is rejected intentionally (SonarQube S5332).
    # Only https:// is accepted; plain HTTP exposes image traffic to interception.
    if not url.startswith("https://"):
        return None, "invalid_format"

    # Strip query params — they often contain tracking tokens that expire
    url = url.split("?")[0]

    # Basic format check — must end with image extension or contain image CDN pattern
    valid_extensions = (".jpg", ".jpeg", ".png", ".webp")
    has_valid_ext    = any(url.lower().endswith(ext) for ext in valid_extensions)
    is_cdn_url       = any(cdn in url for cdn in ["alicdn", "aliexpress", "amazon", "shopify"])

    if not has_valid_ext and not is_cdn_url:
        return None, "not_image_url"

    return url, "ok"
