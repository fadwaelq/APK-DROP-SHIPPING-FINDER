# layer4_generator/generator.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 4 — Main Generator
# ─────────────────────────────────────────────────────────────────────────────
# The single entry point for all content generation.
# Decides automatically whether to use template engine or Gemini Nano.
#
# Usage:
#   from generator import ContentGenerator
#
#   result = ContentGenerator().generate(layer3_output_dict)
#   print(result.product_title)
#   print(result.product_description)
# ─────────────────────────────────────────────────────────────────────────────

from __future__ import annotations
from typing import Union

from models import GeneratorInput, GeneratorOutput
from template_engine import TemplateEngine
from gemini_nano_engine import GeminiNanoEngine


# ─────────────────────────────────────────────────────────────────────────────
# CONTENT GENERATOR — PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────

class ContentGenerator:
    """
    Layer 4 main generator.

    Automatically selects the best available engine:
      - gemini_nano_available=True  → GeminiNanoEngine (template + AI refinement)
      - gemini_nano_available=False → TemplateEngine (template only)

    The Android team sets gemini_nano_available based on device capability check.
    On your local machine, use use_simulator=True to test Gemini Nano flow.
    """

    def __init__(
        self,
        gemini_nano_available: bool = False,
        use_simulator:         bool = False,
    ):
        self._gemini_available = gemini_nano_available
        self._template_engine  = TemplateEngine()
        self._gemini_engine    = GeminiNanoEngine(use_simulator=use_simulator)

    def generate(
        self,
        layer3_output: Union[dict, GeneratorInput],
        target_language: str = "en",
    ) -> GeneratorOutput:
        """
        Main entry point — call with Layer 3 output dict.

        Args:
            layer3_output:   dict from Layer 3 ScoringOutput.to_dict()
                             OR a GeneratorInput instance directly
            target_language: ISO 639-1 code for output language.
                             en/fr/es/de/it/pt/ar/zh

        Returns:
            GeneratorOutput with product_title and product_description
            in the requested language
        """
        if isinstance(layer3_output, dict):
            layer3_output["target_language"] = target_language
            inp = GeneratorInput.from_layer3_output(layer3_output)
        else:
            inp = layer3_output
            inp.target_language = target_language

        if self._gemini_available:
            return self._gemini_engine.generate(inp)
        else:
            return self._template_engine.generate(inp)

    def get_prompts(self, layer3_output: Union[dict, GeneratorInput]) -> dict:
        """
        Returns the Gemini Nano prompts for a given Layer 3 output.
        Useful for the Android team to inspect what gets sent to AICore.
        """
        if isinstance(layer3_output, dict):
            inp = GeneratorInput.from_layer3_output(layer3_output)
        else:
            inp = layer3_output

        return self._gemini_engine.get_prompts(inp)
