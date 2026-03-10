# preprocessing/constants.py
# ─────────────────────────────────────────────────────────────────────────────
# All rules, patterns, and thresholds for DOM data cleaning.
# ─────────────────────────────────────────────────────────────────────────────

import re

# ── Text Limits ───────────────────────────────────────────────────────────────
TEXT_MIN_WORDS       = 10     # below this → text is too short to be useful
TEXT_MAX_WORDS       = 400    # above this → truncate, keep opening paragraphs
TEXT_MIN_CHARS       = 30     # absolute minimum character count

# ── Price Limits ──────────────────────────────────────────────────────────────
PRICE_MIN            = 0.10   # below this → likely a parsing error
PRICE_MAX            = 9999.0 # above this → likely a parsing error

# ── Rating Limits ─────────────────────────────────────────────────────────────
RATING_MIN           = 1.0
RATING_MAX           = 5.0

# ── Image Requirements ────────────────────────────────────────────────────────
IMAGE_MIN_SIZE       = 224    # minimum width or height in pixels
IMAGE_VALID_FORMATS  = {"JPEG", "JPG", "PNG", "WEBP"}

# ── HTML Entities — common ones from AliExpress DOM ──────────────────────────
HTML_ENTITIES = {
    "&amp;":   "&",
    "&lt;":    "<",
    "&gt;":    ">",
    "&nbsp;":  " ",
    "&quot;":  '"',
    "&#39;":   "'",
    "&apos;":  "'",
    "&bull;":  "•",
    "&middot;": "·",
    "&#x27;":  "'",
    "&#x2F;":  "/",
}

# ── Truncation Patterns — AliExpress "read more" artifacts ───────────────────
TRUNCATION_PATTERNS = [
    re.compile(r'\.{3}\s*(read more|show more|see more|voir plus)', re.IGNORECASE),
    re.compile(r'\.\.\.$'),
    re.compile(r'\[more\]', re.IGNORECASE),
]

# ── Noise Phrases — boilerplate text to strip ────────────────────────────────
NOISE_PHRASES = [
    "free shipping",
    "ships from",
    "seller guarantee",
    "buyer protection",
    "30-day return",
    "30 day return",
    "money back guarantee",
    "add to cart",
    "add to wishlist",
    "best seller",
    "top seller",
    "limited time offer",
    "flash sale",
    "coupon",
    "discount code",
]

# ── Currency Symbols — for price parsing ─────────────────────────────────────
CURRENCY_SYMBOLS = ["$", "€", "£", "¥", "₹", "USD", "EUR", "GBP"]

# ── Fallback Values — used when a field cannot be extracted ──────────────────
FALLBACK = {
    "price":        None,    # None means → ask user to enter manually
    "shipping":     0.0,     # assume free shipping if not found
    "order_proxy":  0,       # unknown popularity
    "rating":       0.0,     # unknown rating
    "description":  "",      # empty string → Layer 2 skipped
    "image_url":    None,    # None means → no image available
}
