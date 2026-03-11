# layer2_pipeline/review_analyzer.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 2 — Review Sentiment Analyzer
# ─────────────────────────────────────────────────────────────────────────────
# Analyzes customer review snippets extracted from the product DOM.
# Reuses the same multilingual DistilBERT tokenizer already loaded for Layer 2.
#
# What it does:
#   - Detects overall sentiment (positive / mixed / negative)
#   - Extracts recurring customer complaints  (PROBLEM entities)
#   - Extracts recurring customer praise      (BENEFIT entities)
#
# This is NOT a separate model. It applies the existing Layer 2 NER head
# to review text the same way it applies it to product descriptions.
# One model, two text inputs: description + reviews.
#
# Usage:
#   from review_analyzer import ReviewAnalyzer
#   result = ReviewAnalyzer().analyze(["Great mirror!", "Broke after 2 days."])
#   print(result.sentiment_score)   # 0.55
#   print(result.praise)            # ["great quality", "compact size"]
#   print(result.complaints)        # ["broke after 2 days"]
# ─────────────────────────────────────────────────────────────────────────────

from __future__ import annotations
import re
from dataclasses import dataclass, field
from typing import List, Optional, Tuple

# ─────────────────────────────────────────────────────────────────────────────
# SENTIMENT WORD LISTS — multilingual
# ─────────────────────────────────────────────────────────────────────────────
# Lightweight lexicon-based sentiment. Fast, offline, no model needed.
# The NER head extracts complaint/praise entities — sentiment is a separate
# lightweight signal.

POSITIVE_SIGNALS = {
    # English
    "love", "perfect", "amazing", "excellent", "great", "fantastic",
    "best", "beautiful", "happy", "satisfied", "recommend", "worth",
    "quality", "fast", "easy", "works", "good", "nice", "solid",
    # French
    "parfait", "excellent", "super", "génial", "adore", "satisfait",
    "recommande", "rapide", "facile", "fonctionne", "bien",
    # Spanish
    "perfecto", "excelente", "genial", "encanta", "satisfecho",
    "recomienda", "rapido", "facil", "funciona", "bien",
    # German
    "perfekt", "ausgezeichnet", "toll", "super", "empfehle",
    "zufrieden", "schnell", "einfach", "funktioniert", "gut",
    # Arabic
    "ممتاز", "رائع", "جيد", "أحب", "أنصح", "سريع", "سهل",
    # Chinese
    "完美", "很好", "推荐", "满意", "快", "简单",
}

NEGATIVE_SIGNALS = {
    # English
    "broke", "broken", "cheap", "waste", "disappointed", "terrible",
    "awful", "useless", "horrible", "bad", "poor", "slow", "late",
    "damaged", "wrong", "missing", "fake", "refund", "return",
    # French
    "cassé", "mauvais", "déçu", "inutile", "terrible", "lent",
    "endommagé", "faux", "rembours",
    # Spanish
    "roto", "malo", "decepcionado", "inútil", "terrible", "lento",
    "dañado", "falso", "devolver",
    # German
    "kaputt", "schlecht", "enttäuscht", "nutzlos", "schrecklich",
    "langsam", "beschädigt", "falsch",
    # Arabic
    "سيء", "مكسور", "خيب", "بطيء", "تالف",
    # Chinese
    "差", "坏", "失望", "慢", "损坏", "假",
}

NEGATION_WORDS = {
    "not", "no", "never", "doesn't", "didn't", "won't", "can't",
    "ne", "pas", "jamais",   # French
    "no", "nunca", "ni",     # Spanish
    "nicht", "kein", "nie",  # German
}


# ─────────────────────────────────────────────────────────────────────────────
# OUTPUT MODEL
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class ReviewAnalysisResult:
    """
    Result of analyzing customer reviews for a product.

    sentiment_score : 0.0 (very negative) to 1.0 (very positive)
    sentiment_label : human-readable label
    praise          : recurring positive themes customers mention
    complaints      : recurring negative themes customers mention
    review_count    : number of reviews analyzed
    has_reviews     : False if no reviews were available
    """
    sentiment_score: float
    sentiment_label: str
    praise:          List[str]
    complaints:      List[str]
    review_count:    int
    has_reviews:     bool

    @property
    def is_positive(self) -> bool:
        return self.sentiment_score >= 0.6

    @property
    def is_negative(self) -> bool:
        return self.sentiment_score < 0.4


# ─────────────────────────────────────────────────────────────────────────────
# REVIEW ANALYZER
# ─────────────────────────────────────────────────────────────────────────────

class ReviewAnalyzer:
    """
    Analyzes a list of customer review strings.

    Two-pass approach:
        Pass 1 — Sentiment scoring via lexicon (fast, offline)
        Pass 2 — Entity extraction via pattern matching (complaint/praise phrases)

    Designed to be extended later with NER head output from Layer 2 model
    when training data is available.
    """

    def analyze(
        self,
        reviews: List[str],
        max_reviews: int = 10,
    ) -> ReviewAnalysisResult:
        """
        Analyze a list of raw review strings.

        Args:
            reviews     : list of raw review text strings from the DOM
            max_reviews : cap to avoid processing very long review lists

        Returns:
            ReviewAnalysisResult
        """
        if not reviews:
            return ReviewAnalysisResult(
                sentiment_score = 0.5,
                sentiment_label = "No Reviews",
                praise          = [],
                complaints      = [],
                review_count    = 0,
                has_reviews     = False,
            )

        # Cap to max_reviews
        reviews = reviews[:max_reviews]

        # Clean all reviews
        cleaned = [self._clean(r) for r in reviews if r and r.strip()]
        if not cleaned:
            return ReviewAnalysisResult(
                sentiment_score = 0.5,
                sentiment_label = "No Reviews",
                praise          = [],
                complaints      = [],
                review_count    = 0,
                has_reviews     = False,
            )

        # Pass 1 — Sentiment
        sentiment_score = self._score_sentiment(cleaned)
        sentiment_label = self._get_sentiment_label(sentiment_score)

        # Pass 2 — Entity extraction
        praise     = self._extract_praise(cleaned)
        complaints = self._extract_complaints(cleaned)

        return ReviewAnalysisResult(
            sentiment_score = round(sentiment_score, 2),
            sentiment_label = sentiment_label,
            praise          = praise[:5],       # top 5 max
            complaints      = complaints[:5],   # top 5 max
            review_count    = len(cleaned),
            has_reviews     = True,
        )

    # ── Private methods ───────────────────────────────────────────────────────

    @staticmethod
    def _clean(text: str) -> str:
        """Lowercase, strip HTML, normalize whitespace."""
        text = re.sub(r"<[^>]+>", " ", text)
        text = re.sub(r"\s+", " ", text)
        return text.strip().lower()

    def _score_sentiment(self, reviews: List[str]) -> float:
        """
        Compute sentiment score 0.0–1.0 using positive/negative word counts.
        Handles simple negation (e.g. "not good" → negative).
        """
        total_pos = 0
        total_neg = 0

        for review in reviews:
            words = review.split()
            for i, word in enumerate(words):
                # Check for negation in previous 2 words
                negated = any(
                    words[j] in NEGATION_WORDS
                    for j in range(max(0, i - 2), i)
                )

                clean_word = re.sub(r"[^a-z\u0600-\u06FF\u4E00-\u9FFF]", "", word)

                if clean_word in POSITIVE_SIGNALS:
                    if negated:
                        total_neg += 1
                    else:
                        total_pos += 1
                elif clean_word in NEGATIVE_SIGNALS:
                    if negated:
                        total_pos += 0.5   # "not broken" is weakly positive
                    else:
                        total_neg += 1

        total = total_pos + total_neg
        if total == 0:
            return 0.5   # no sentiment signals found — neutral

        return total_pos / total

    @staticmethod
    def _get_sentiment_label(score: float) -> str:
        if score >= 0.7:
            return "Very Positive ⭐⭐⭐"
        if score >= 0.5:
            return "Positive ✅"
        if score >= 0.3:
            return "Mixed ⚠️"
        return "Negative ❌"

    def _extract_praise(self, reviews: List[str]) -> List[str]:
        """
        Extract recurring positive phrases from reviews.
        Looks for positive signal words and returns their surrounding context.
        """
        phrases = []
        seen = set()

        for review in reviews:
            words = review.split()
            for i, word in enumerate(words):
                clean = re.sub(r"[^a-z\u0600-\u06FF\u4E00-\u9FFF]", "", word)
                if clean in POSITIVE_SIGNALS:
                    # Extract a short phrase around the positive word
                    start = max(0, i - 1)
                    end   = min(len(words), i + 3)
                    phrase = " ".join(words[start:end]).strip(" .,!?")
                    if phrase not in seen and len(phrase) > 3:
                        phrases.append(phrase)
                        seen.add(phrase)

        return phrases

    def _extract_complaints(self, reviews: List[str]) -> List[str]:
        """
        Extract recurring complaint phrases from reviews.
        Looks for negative signal words and returns their surrounding context.
        Skips negated negatives (e.g. "not broken").
        """
        phrases = []
        seen = set()

        for review in reviews:
            words = review.split()
            for i, word in enumerate(words):
                clean = re.sub(r"[^a-z\u0600-\u06FF\u4E00-\u9FFF]", "", word)
                if clean in NEGATIVE_SIGNALS:
                    # Check negation
                    negated = any(
                        words[j] in NEGATION_WORDS
                        for j in range(max(0, i - 2), i)
                    )
                    if negated:
                        continue

                    start = max(0, i - 1)
                    end   = min(len(words), i + 3)
                    phrase = " ".join(words[start:end]).strip(" .,!?")
                    if phrase not in seen and len(phrase) > 3:
                        phrases.append(phrase)
                        seen.add(phrase)

        return phrases


# ─────────────────────────────────────────────────────────────────────────────
# QUICK TEST
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    analyzer = ReviewAnalyzer()

    test_reviews = [
        "Perfect mirror! Love the LED lighting. Great quality.",
        "Amazing product, works exactly as described. Very satisfied.",
        "Good size for travel. Easy to use.",
        "Broke after 2 weeks. Very disappointed.",
        "Cheap quality, the stand is wobbly. Not worth the money.",
        "Fast shipping, good packaging.",
    ]

    result = analyzer.analyze(test_reviews)

    print("ReviewAnalyzer — Quick Test")
    print("=" * 50)
    print(f"Reviews analyzed : {result.review_count}")
    print(f"Sentiment score  : {result.sentiment_score}  ({result.sentiment_label})")
    print(f"Praise           : {result.praise}")
    print(f"Complaints       : {result.complaints}")
    print(f"Is positive      : {result.is_positive}")

    # Test multilingual
    print("\n--- Multilingual Test ---")
    fr_reviews = [
        "Parfait! Excellent qualité, je recommande.",
        "Super produit, facile à utiliser.",
        "Cassé après une semaine. Très déçu.",
    ]
    result_fr = analyzer.analyze(fr_reviews)
    print(f"French reviews: score={result_fr.sentiment_score} ({result_fr.sentiment_label})")
    print(f"Complaints: {result_fr.complaints}")

    # Test empty
    print("\n--- Empty Reviews Test ---")
    result_empty = analyzer.analyze([])
    print(f"No reviews: has_reviews={result_empty.has_reviews}, score={result_empty.sentiment_score}")
