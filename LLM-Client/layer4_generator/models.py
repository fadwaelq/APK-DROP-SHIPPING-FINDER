# layer4_generator/models.py
# ─────────────────────────────────────────────────────────────────────────────
# Input and output data models for Layer 4.
# Layer 3 output is passed directly as input here.
# ─────────────────────────────────────────────────────────────────────────────

from dataclasses import dataclass, asdict
from typing import List, Optional
import json


# ─────────────────────────────────────────────────────────────────────────────
# LAYER 4 INPUT — comes directly from Layer 3 ScoringOutput
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class GeneratorInput:
    """
    Input to Layer 4.
    All fields come from Layer 3 ScoringOutput — no extra user input needed.
    """
    product_name:     str
    usp:              str
    main_promise:     str
    marketing_angle:  str              # one of 7 angles
    key_features:     List[str]
    category:         str
    market_type:      str              # mass | niche | premium
    problem_solved:   str
    target_audience:  List[str]
    target_language:  str = "en"       # ISO 639-1: en/fr/es/de/it/pt/ar/zh

    @classmethod
    def from_layer3_output(cls, layer3_dict: dict) -> "GeneratorInput":
        return cls(
            product_name    = layer3_dict.get("product_name",    ""),
            usp             = layer3_dict.get("usp",             ""),
            main_promise    = layer3_dict.get("main_promise",    ""),
            marketing_angle = layer3_dict.get("marketing_angle", "convenience"),
            key_features    = layer3_dict.get("key_features",    []),
            category        = layer3_dict.get("category",        "gadget"),
            market_type     = layer3_dict.get("market_type",     "mass"),
            problem_solved  = layer3_dict.get("problem_solved",  ""),
            target_audience = layer3_dict.get("target_audience", []),
            target_language = layer3_dict.get("target_language", "en"),
        )


# ─────────────────────────────────────────────────────────────────────────────
# LAYER 4 OUTPUT — the generated content
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class GeneratorOutput:
    """
    Complete output from Layer 4.
    Contains both generated content and metadata about how it was generated.
    """
    # Generated content
    product_title:       str
    product_description: str

    # Generation metadata
    generation_mode:     str   # "template" | "gemini_nano"
    marketing_angle:     str
    tone:                str
    target_language:     str = "en"   # language of the generated content

    def to_dict(self) -> dict:
        return asdict(self)

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), indent=2)

    def summary(self) -> str:
        return (
            f"[{self.generation_mode.upper()}] "
            f"Title: {self.product_title[:60]}..."
        )
