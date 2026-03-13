"""
Layer 2 — Post Processor
=========================
Takes raw model output (NER tags + classification)
and derives the final structured JSON for Layer 3 and Layer 4.

No ML here — pure rule-based logic.
This runs in Python (server-side processing) AND
is reimplemented in Dart for on-device Flutter inference.
"""

from dataclasses import dataclass, field, asdict
from typing import List, Dict
import json
import re


# ─────────────────────────────────────────────────────────────────────────────
# POWER WORDS — category-specific high-signal features
# Used to rank features and identify the USP
# ─────────────────────────────────────────────────────────────────────────────

POWER_WORDS: Dict[str, List[str]] = {
    "gadget":             ["wireless", "rechargeable", "portable", "smart", "automatic", "sensor"],
    "beauty":             ["magnification", "led", "microcurrent", "waterproof", "dermatologist"],
    "home_kitchen":       ["dishwasher safe", "non-stick", "stainless", "airtight", "fda approved"],
    "fashion_accessories": ["genuine leather", "handcrafted", "adjustable", "anti-tarnish"],
    "pet_kids":           ["non-toxic", "chew-proof", "vet approved", "bpa free", "washable"],
    "fitness_outdoor":    ["resistance", "anti-slip", "waterproof", "breathable", "adjustable"],
}


# ─────────────────────────────────────────────────────────────────────────────
# DATA CLASSES
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class ExtractionResult:
    product_name:     str        = ""
    key_features:     List[str]  = field(default_factory=list)
    target_audience:  List[str]  = field(default_factory=list)
    problem_solved:   str        = ""
    main_benefit:     str        = ""
    usp:              str        = ""
    main_promise:     str        = ""
    marketing_angle:  str        = ""
    audience_size:    str        = ""

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2)


# ─────────────────────────────────────────────────────────────────────────────
# SPAN EXTRACTOR — groups consecutive BIO tags into text spans
# ─────────────────────────────────────────────────────────────────────────────

def _flush_span(spans: Dict[str, List[str]], entity: str, tokens: List[str]) -> None:
    """Append the accumulated token span to spans if non-empty."""
    if entity and tokens:
        spans[entity].append(" ".join(tokens))


def extract_spans(tokens: List[str], labels: List[str]) -> Dict[str, List[str]]:
    """
    Input:
        tokens: ["Portable", "LED", "Makeup", "Mirror", "with", "10x", ...]
        labels: ["B-PRODUCT", "I-PRODUCT", "I-PRODUCT", "I-PRODUCT", "O", "B-FEATURE", ...]

    Output:
        {
            "PRODUCT":  ["Portable LED Makeup Mirror"],
            "FEATURE":  ["10x magnification", "360° rotation", "USB rechargeable"],
            "AUDIENCE": ["travel", "Women"],
            "PROBLEM":  ["bad lighting"],
            "BENEFIT":  [],
        }
    """
    spans: Dict[str, List[str]] = {
        "PRODUCT":  [],
        "FEATURE":  [],
        "AUDIENCE": [],
        "PROBLEM":  [],
        "BENEFIT":  [],
    }

    current_entity = None
    current_tokens = []

    for token, label in zip(tokens, labels):
        if label.startswith("B-"):
            _flush_span(spans, current_entity, current_tokens)
            current_entity = label[2:]   # strip "B-"
            current_tokens = [token]
        elif label.startswith("I-") and current_entity == label[2:]:
            current_tokens.append(token)
        else:
            _flush_span(spans, current_entity, current_tokens)
            current_entity = None
            current_tokens = []

    _flush_span(spans, current_entity, current_tokens)
    return spans


# ─────────────────────────────────────────────────────────────────────────────
# USP DERIVATION — picks the strongest feature as the USP
# ─────────────────────────────────────────────────────────────────────────────

def derive_usp(features: List[str], category: str) -> str:
    """
    Score each feature and return the highest-scoring one as the USP.

    Scoring rules:
        +3 if feature contains a number (specific = credible)
        +2 if feature is short (<=4 words = punchy)
        +2 if feature contains a category power word
    """
    if not features:
        return ""

    power_words = POWER_WORDS.get(category, [])
    scored      = []

    for feature in features:
        score = 0
        if re.search(r'\d', feature):
            score += 3
        if len(feature.split()) <= 4:
            score += 2
        if any(pw in feature.lower() for pw in power_words):
            score += 2
        scored.append((feature, score))

    best_feature = max(scored, key=lambda x: x[1])[0]
    return best_feature


# ─────────────────────────────────────────────────────────────────────────────
# MAIN PROMISE DERIVATION
# ─────────────────────────────────────────────────────────────────────────────

PROMISE_TEMPLATES = {
    "problem_solution": "Solves {problem} — finally",
    "transformation":   "Transform with {usp}",
    "social_proof":     "The {product} everyone is buying",
    "curiosity":        "Discover what {usp} can do",
    "convenience":      "{usp} in seconds",
    "identity":         "For people who need {usp}",
    "value":            "Get {usp} — worth every penny",
}

def derive_main_promise(
    angle: str,
    product_name: str,
    usp: str,
    problem: str,
) -> str:
    template = PROMISE_TEMPLATES.get(angle, "{usp}")
    return template.format(
        problem=problem   or "the problem",
        usp=usp           or product_name,
        product=product_name,
    )


# ─────────────────────────────────────────────────────────────────────────────
# MAIN POST-PROCESSOR
# ─────────────────────────────────────────────────────────────────────────────

def post_process(
    tokens:          List[str],
    ner_labels:      List[str],
    angle_id:        int,
    audience_id:     int,
    category:        str,
    angle_labels:    List[str],
    audience_labels: List[str],
) -> ExtractionResult:
    """
    Full post-processing pipeline.
    Called after model inference with decoded predictions.
    """
    from model import ANGLE_LABELS, AUDIENCE_LABELS

    # 1. Extract spans from BIO tags
    spans = extract_spans(tokens, ner_labels)

    # 2. Derive structured fields
    product_name    = spans["PRODUCT"][0]   if spans["PRODUCT"]  else ""
    key_features    = spans["FEATURE"]
    target_audience = spans["AUDIENCE"]
    problem_solved  = spans["PROBLEM"][0]   if spans["PROBLEM"]  else ""
    main_benefit    = spans["BENEFIT"][0]   if spans["BENEFIT"]  else ""

    # 3. Derive USP
    usp = derive_usp(key_features, category)

    # 4. Decode classification labels
    marketing_angle = angle_labels[angle_id]
    audience_size   = audience_labels[audience_id]

    # 5. Derive main promise
    main_promise = derive_main_promise(
        angle=marketing_angle,
        product_name=product_name,
        usp=usp,
        problem=problem_solved,
    )

    return ExtractionResult(
        product_name=product_name,
        key_features=key_features,
        target_audience=target_audience,
        problem_solved=problem_solved,
        main_benefit=main_benefit,
        usp=usp,
        main_promise=main_promise,
        marketing_angle=marketing_angle,
        audience_size=audience_size,
    )


# ─────────────────────────────────────────────────────────────────────────────
# QUICK TEST
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Simulated model output (as if model predicted these labels)
    tokens = [
        "Portable", "LED", "Makeup", "Mirror", "with",
        "10x", "magnification", "and", "360", "degree", "rotation", ".",
        "USB", "rechargeable", ".", "Perfect", "for", "travel", ".",
        "Women", "love", "this", ".", "Never", "struggle", "with",
        "bad", "lighting", "again", "."
    ]
    ner_labels = [
        "B-PRODUCT", "I-PRODUCT", "I-PRODUCT", "I-PRODUCT", "O",
        "B-FEATURE", "I-FEATURE", "O", "B-FEATURE", "I-FEATURE", "I-FEATURE", "O",
        "B-FEATURE", "I-FEATURE", "O", "O", "O", "B-AUDIENCE", "O",
        "B-AUDIENCE", "O", "O", "O", "B-PROBLEM", "I-PROBLEM", "I-PROBLEM",
        "I-PROBLEM", "I-PROBLEM", "I-PROBLEM", "O"
    ]

    from model import ANGLE_LABELS, AUDIENCE_LABELS

    result = post_process(
        tokens=tokens,
        ner_labels=ner_labels,
        angle_id=1,          # transformation
        audience_id=0,       # mass
        category="beauty",
        angle_labels=ANGLE_LABELS,
        audience_labels=AUDIENCE_LABELS,
    )

    print("── Post-Processor Output ─────────────────────────")
    print(result.to_json())
    print("──────────────────────────────────────────────────")
