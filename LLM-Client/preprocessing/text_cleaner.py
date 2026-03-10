# preprocessing/text_cleaner.py
# ─────────────────────────────────────────────────────────────────────────────
# Cleans raw product description text extracted from the DOM.
# Prepares it for Layer 2 (DistilBERT) inference.
# ─────────────────────────────────────────────────────────────────────────────

import re
import unicodedata
from typing import List, Optional, Tuple

from constants import (
    HTML_ENTITIES, TRUNCATION_PATTERNS, NOISE_PHRASES,
    TEXT_MIN_WORDS, TEXT_MAX_WORDS, TEXT_MIN_CHARS,
)


# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Strip HTML
# ─────────────────────────────────────────────────────────────────────────────

def strip_html_tags(text: str) -> str:
    """Remove any residual HTML tags from DOM-extracted text."""
    return re.sub(r'<[^>]+>', ' ', text)

def decode_html_entities(text: str) -> str:
    """Replace common HTML entities with their text equivalents."""
    for entity, replacement in HTML_ENTITIES.items():
        text = text.replace(entity, replacement)
    # Handle numeric entities like &#160;
    text = re.sub(r'&#(\d+);',  lambda m: chr(int(m.group(1))),  text)
    text = re.sub(r'&#x([0-9a-fA-F]+);', lambda m: chr(int(m.group(1), 16)), text)
    return text


# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Remove Non-Text Content
# ─────────────────────────────────────────────────────────────────────────────

def remove_emojis(text: str) -> str:
    """Strip emoji and pictographic characters."""
    return ''.join(
        c for c in text
        if not unicodedata.category(c).startswith('So')  # Symbol, other
        and ord(c) < 0x1F000   # covers most emoji ranges
    )

def remove_urls(text: str) -> str:
    """Remove URLs that sometimes appear in DOM-extracted descriptions."""
    return re.sub(r'https?://\S+|www\.\S+', '', text)

def remove_special_chars(text: str) -> str:
    """
    Remove special characters but keep:
    - Letters and numbers
    - Basic punctuation (. , ! ? : ; - ')
    - Degree symbol ° (used in product specs like "360°")
    - % and × (used in specs like "10x magnification", "50%")
    - Ampersand & (used in product names like "Opener & Can Opener")
    """
    # Step 1 — remove non-printable control characters
    text = re.sub(r'[\x00-\x1f\x7f-\x9f]', ' ', text)
    # Step 2 — remove remaining non-useful symbols
    text = re.sub(r'[^\w\s.,!?:;\-\'°%×xX&]', ' ', text)
    return text


# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Handle Mixed Language
# ─────────────────────────────────────────────────────────────────────────────

def extract_english_segments(text: str) -> str:
    """
    AliExpress descriptions often contain Chinese mixed with English.
    Keep only segments that are predominantly ASCII (English).
    A segment is kept if >70% of its characters are ASCII.
    """
    segments = re.split(r'[\n\r。！？；]', text)
    english_segments = []

    for segment in segments:
        segment = segment.strip()
        if not segment:
            continue

        ascii_count = sum(1 for c in segment if ord(c) < 128)
        ascii_ratio = ascii_count / len(segment)

        if ascii_ratio > 0.70:
            english_segments.append(segment)

    return ' '.join(english_segments)


# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — Clean Truncation and Noise
# ─────────────────────────────────────────────────────────────────────────────

def remove_truncation_artifacts(text: str) -> str:
    """Remove 'read more', '...', and similar truncation artifacts."""
    for pattern in TRUNCATION_PATTERNS:
        text = pattern.sub('', text)
    return text

def remove_noise_phrases(text: str) -> str:
    """
    Remove boilerplate shipping/policy phrases inline.
    Strips the phrase itself rather than dropping the whole line,
    avoids losing product content on the same line.
    """
    for phrase in NOISE_PHRASES:
        text = re.sub(re.escape(phrase), "", text, flags=re.IGNORECASE)
    return text


# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — Normalize Whitespace
# ─────────────────────────────────────────────────────────────────────────────

def normalize_whitespace(text: str) -> str:
    """Collapse multiple spaces and newlines into single space."""
    text = re.sub(r'\s+', ' ', text)
    return text.strip()


# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 — Truncate to Max Length
# ─────────────────────────────────────────────────────────────────────────────

def truncate_to_max_words(text: str, max_words: int = TEXT_MAX_WORDS) -> str:
    """
    Truncate text to max_words.
    Cuts at sentence boundary when possible to keep text coherent.
    """
    words = text.split()
    if len(words) <= max_words:
        return text

    truncated = ' '.join(words[:max_words])

    # Try to end at a sentence boundary
    last_period = max(
        truncated.rfind('.'),
        truncated.rfind('!'),
        truncated.rfind('?'),
    )

    if last_period > len(truncated) * 0.7:   # only if period is in last 30%
        return truncated[:last_period + 1]

    return truncated


# ─────────────────────────────────────────────────────────────────────────────
# VALIDATION
# ─────────────────────────────────────────────────────────────────────────────

def validate_text(text: str) -> Tuple[bool, str]:
    """
    Returns (is_valid, reason).
    Invalid text is not sent to Layer 2.
    """
    if not text or not text.strip():
        return False, "Empty text"

    if len(text) < TEXT_MIN_CHARS:
        return False, f"Too short ({len(text)} chars)"

    word_count = len(text.split())
    if word_count < TEXT_MIN_WORDS:
        return False, f"Too few words ({word_count})"

    return True, "OK"


# ─────────────────────────────────────────────────────────────────────────────
# MAIN CLEANER — PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────

def clean_description(raw_text: Optional[str]) -> Tuple[str, List[str]]:
    """
    Full text cleaning pipeline.
    Returns (clean_text, warnings_list).

    Steps:
        1. Strip HTML tags and decode entities
        2. Remove emojis, URLs, special chars
        3. Extract English segments (handle mixed Chinese/English)
        4. Remove truncation artifacts and noise phrases
        5. Normalize whitespace
        6. Truncate to max words
        7. Validate result
    """
    warnings = []

    if not raw_text:
        return "", ["No description provided"]

    text = raw_text

    # Step 1
    text = strip_html_tags(text)
    text = decode_html_entities(text)

    # Step 2
    text = remove_emojis(text)
    text = remove_urls(text)
    text = remove_special_chars(text)

    # Step 3
    original_len = len(text.split())
    text = extract_english_segments(text)
    new_len = len(text.split())
    if new_len < original_len * 0.5:
        warnings.append(f"Heavy non-English content removed ({original_len} → {new_len} words)")

    # Step 4
    text = remove_truncation_artifacts(text)
    text = remove_noise_phrases(text)

    # Step 5
    text = normalize_whitespace(text)

    # Step 6
    word_count = len(text.split())
    if word_count > TEXT_MAX_WORDS:
        text = truncate_to_max_words(text)
        warnings.append(f"Text truncated from {word_count} to {TEXT_MAX_WORDS} words")

    # Step 7
    is_valid, reason = validate_text(text)
    if not is_valid:
        warnings.append(f"Text invalid after cleaning: {reason}")
        return "", warnings

    return text, warnings
