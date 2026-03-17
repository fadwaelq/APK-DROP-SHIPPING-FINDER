# preprocessing/text_cleaner.py
# ─────────────────────────────────────────────────────────────────────────────
# Cleans raw product description text extracted from the DOM.
# Prepares it for Layer 2 (DistilBERT) inference.
# ─────────────────────────────────────────────────────────────────────────────

import re
import unicodedata
from typing import Dict, List, Optional, Tuple

from constants import (
    HTML_ENTITIES, TRUNCATION_PATTERNS, NOISE_PHRASES,
    TEXT_MIN_WORDS, TEXT_MAX_WORDS, TEXT_MIN_CHARS,
    ARABIC_INDIC_NUMERALS, SUPPORTED_LANGUAGES, DEFAULT_LANGUAGE,
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
# STEP 2b — Arabic Numeral Normalization
# ─────────────────────────────────────────────────────────────────────────────

def normalize_arabic_numerals(text: str) -> str:
    """
    Convert Eastern Arabic-Indic numerals to ASCII digits.
    Example: ٤٫٥٠ → 4.50
    Required for Arabic price and rating parsing.
    """
    for arabic, ascii_char in ARABIC_INDIC_NUMERALS.items():
        text = text.replace(arabic, ascii_char)
    return text


# ─────────────────────────────────────────────────────────────────────────────
# LANGUAGE DETECTION
# ─────────────────────────────────────────────────────────────────────────────

def detect_language(text: str) -> str:
    """
    Lightweight language detection based on character set analysis.
    Returns a language code from SUPPORTED_LANGUAGES.

    Strategy:
        - Arabic Unicode range  → "ar"
        - CJK Unicode range     → "zh"
        - Latin + French chars  → "fr" hint (refined by keyword check)
        - Latin + Spanish chars → "es" hint
        - Default               → "en"

    Note: This is a fast heuristic, not a full language model.
    For production, replace with langdetect or fastText if accuracy is critical.
    """
    if not text:
        return DEFAULT_LANGUAGE

    # Count characters by script
    arabic_count = sum(1 for c in text if "؀" <= c <= "ۿ")
    cjk_count    = sum(1 for c in text if "一" <= c <= "鿿")
    total        = max(len(text), 1)

    if arabic_count / total > 0.15:
        return "ar"
    if cjk_count / total > 0.15:
        return "zh"

    # Latin-script language hints from common function words
    text_lower = text.lower()
    fr_signals = ["le ", "la ", "les ", "de ", "du ", "des ", "un ", "une ", "est ", "avec "]
    es_signals = ["el ", "la ", "los ", "las ", "de ", "del ", "con ", "para ", "por ", "es "]
    de_signals = ["der ", "die ", "das ", "ein ", "eine ", "und ", "mit ", "von ", "ist "]
    it_signals = ["il ", "la ", "le ", "di ", "del ", "con ", "per ", "che ", "una "]
    pt_signals = ["o ", "a ", "os ", "as ", "de ", "do ", "da ", "com ", "para ", "por "]

    def _score(signals: List[str]) -> int:
        return sum(1 for s in signals if s in text_lower)

    scores: Dict[str, int] = {
        "fr": _score(fr_signals),
        "es": _score(es_signals),
        "de": _score(de_signals),
        "it": _score(it_signals),
        "pt": _score(pt_signals),
    }

    best_lang  = max(scores, key=lambda k: scores[k])
    best_score = scores[best_lang]

    # Only assign non-English if the signal is strong enough
    if best_score >= 3:
        return best_lang

    return DEFAULT_LANGUAGE


# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Handle Mixed Language
# ─────────────────────────────────────────────────────────────────────────────

def _segment_matches_language(segment: str, language: str) -> bool:
    """
    Return True if the segment contains enough characters for the target script.
    Extracted to reduce cognitive complexity of extract_dominant_language_segments
    (SonarQube S3776).
    """
    total = len(segment)
    if language == "ar":
        arabic_count = sum(1 for ch in segment if "\u0600" <= ch <= "\u06FF")
        return arabic_count / total > 0.15
    if language == "zh":
        cjk_count = sum(1 for ch in segment if "\u4E00" <= ch <= "\u9FFF")
        return cjk_count / total > 0.15
    # Latin-script languages: keep predominantly ASCII segments
    ascii_count = sum(1 for ch in segment if ord(ch) < 128)
    return ascii_count / total > 0.60


def extract_dominant_language_segments(text: str, language: str = DEFAULT_LANGUAGE) -> str:
    """
    Keep only segments matching the detected language.

    For Arabic/Chinese — keeps segments with >15% target-script characters.
    For Latin languages — keeps segments with >70% ASCII characters.
    Replaces the old English-only extract_english_segments().
    """
    segments = re.split(r'[\n\r。！？；]', text)
    kept_segments = [
        seg.strip()
        for seg in segments
        if seg.strip() and _segment_matches_language(seg.strip(), language)
    ]
    return ' '.join(kept_segments)


# Keep old name as alias for backward compatibility
def extract_english_segments(text: str) -> str:
    """Backward-compatible alias for extract_dominant_language_segments."""
    return extract_dominant_language_segments(text, "en")


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

def clean_description(
    raw_text: Optional[str],
    language: Optional[str] = None,
) -> Tuple[str, List[str]]:
    """
    Full text cleaning pipeline — multilingual aware.
    Returns (clean_text, warnings_list).

    Args:
        raw_text: raw DOM description string
        language: ISO 639-1 code (en/fr/es/de/it/pt/ar/zh).
                  If None, language is auto-detected.

    Steps:
        1. Strip HTML tags and decode entities
        2. Normalize Arabic-Indic numerals (for Arabic text)
        3. Remove emojis, URLs, special chars
        4. Extract segments matching detected language
        5. Remove truncation artifacts and noise phrases
        6. Normalize whitespace
        7. Truncate to max words
        8. Validate result
    """
    warnings: List[str] = []

    if not raw_text:
        return "", ["No description provided"]

    text = raw_text

    # Step 1
    text = strip_html_tags(text)
    text = decode_html_entities(text)

    # Step 2 — Arabic numeral normalization (safe to run on all languages)
    text = normalize_arabic_numerals(text)

    # Detect language if not provided
    detected_lang = language if language in SUPPORTED_LANGUAGES else detect_language(text)
    if detected_lang != DEFAULT_LANGUAGE:
        warnings.append(f"Language detected: {SUPPORTED_LANGUAGES.get(detected_lang, detected_lang)}")

    # Step 3
    text = remove_emojis(text)
    text = remove_urls(text)
    text = remove_special_chars(text)

    # Step 4 — language-aware segment extraction
    original_len = len(text.split())
    text = extract_dominant_language_segments(text, detected_lang)
    new_len = len(text.split())
    if new_len < original_len * 0.5:
        warnings.append(f"Mixed-language content filtered ({original_len} -> {new_len} words)")

    # Step 5
    text = remove_truncation_artifacts(text)
    text = remove_noise_phrases(text)

    # Step 6
    text = normalize_whitespace(text)

    # Step 7
    word_count = len(text.split())
    if word_count > TEXT_MAX_WORDS:
        text = truncate_to_max_words(text)
        warnings.append(f"Text truncated from {word_count} to {TEXT_MAX_WORDS} words")

    # Step 8
    is_valid, reason = validate_text(text)
    if not is_valid:
        warnings.append(f"Text invalid after cleaning: {reason}")
        return "", warnings

    return text, warnings
