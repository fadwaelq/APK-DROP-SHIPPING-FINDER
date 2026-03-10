# layer4_generator/gemini_nano_engine.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 4 — Gemini Nano Engine
# ─────────────────────────────────────────────────────────────────────────────
# Uses Android's on-device Gemini Nano (via AICore) to refine the
# template engine output into more natural, higher-quality copy.
#
# This module is the PYTHON SIDE only:
#   - Defines the prompt structure
#   - Defines the refinement logic
#   - Defines the output validation
#   - Simulates Gemini Nano for testing (no Android needed on your machine)
#
# The Android/Flutter team will call this logic via a method channel.
# Your deliverable: prompt strings + validation logic in this file.
#
# Availability:
#   Gemini Nano requires Android 14+ with AICore installed.
#   On unsupported devices → falls back to TemplateEngine automatically.
# ─────────────────────────────────────────────────────────────────────────────

import re
from models import GeneratorInput, GeneratorOutput
from template_engine import TemplateEngine
from constants import (
    DEFAULT_TONE,
    GEMINI_TITLE_PROMPT, GEMINI_DESCRIPTION_PROMPT,
    TONE_BY_MARKET,
)


# ─────────────────────────────────────────────────────────────────────────────
# PROMPT BUILDER
# ─────────────────────────────────────────────────────────────────────────────

class PromptBuilder:
    """
    Builds the prompts sent to Gemini Nano.
    The Android team passes these strings to the AICore API.
    """

    @staticmethod
    def build_title_prompt(inp: GeneratorInput) -> str:
        """Build the title generation prompt."""
        audience = (
            inp.target_audience[0]
            if inp.target_audience
            else inp.category.replace("_", " ") + " enthusiasts"
        )
        tone = TONE_BY_MARKET.get(inp.market_type, DEFAULT_TONE)

        return GEMINI_TITLE_PROMPT.format(
            product_name     = inp.product_name,
            usp              = inp.usp,
            marketing_angle  = inp.marketing_angle,
            audience         = audience,
            problem          = inp.problem_solved or "common problems",
            tone             = tone,
        ).strip()

    @staticmethod
    def build_description_prompt(
        inp: GeneratorInput,
        template_output: str,
    ) -> str:
        """
        Build the description refinement prompt.
        Passes template output as context — Gemini refines it, not generates from scratch.
        This keeps the structure correct while improving naturalness.
        """
        features_str = ", ".join(inp.key_features) if inp.key_features else inp.usp
        tone         = TONE_BY_MARKET.get(inp.market_type, DEFAULT_TONE)

        return GEMINI_DESCRIPTION_PROMPT.format(
            template_output  = template_output,
            product_name     = inp.product_name,
            usp              = inp.usp,
            marketing_angle  = inp.marketing_angle,
            features         = features_str,
            problem          = inp.problem_solved or "common problems",
            tone             = tone,
        ).strip()


# ─────────────────────────────────────────────────────────────────────────────
# OUTPUT VALIDATOR
# ─────────────────────────────────────────────────────────────────────────────

class OutputValidator:
    """
    Validates Gemini Nano output before using it.
    If validation fails → fall back to template output.
    """

    @staticmethod
    def validate_title(title: str, inp: GeneratorInput) -> tuple[bool, str]:
        """
        Returns (is_valid, reason).
        """
        if not title or not title.strip():
            return False, "Empty output"

        title = title.strip()

        if len(title) > 100:
            return False, f"Too long ({len(title)} chars)"

        if len(title) < 10:
            return False, f"Too short ({len(title)} chars)"

        # Must contain product name or USP — otherwise it's hallucinated
        product_words = inp.product_name.lower().split()
        usp_words     = inp.usp.lower().split() if inp.usp else []
        combined      = product_words + usp_words

        title_lower = title.lower()
        has_anchor  = any(word in title_lower for word in combined if len(word) > 3)

        if not has_anchor:
            return False, "Title doesn't reference product or USP"

        return True, "OK"

    @staticmethod
    def validate_description(description: str) -> tuple[bool, str]:
        """
        Returns (is_valid, reason).
        """
        if not description or not description.strip():
            return False, "Empty output"

        description = description.strip()
        word_count  = len(description.split())

        if word_count < 30:
            return False, f"Too short ({word_count} words)"

        if word_count > 300:
            return False, f"Too long ({word_count} words)"

        # Flag generic filler — model sometimes ignores instructions
        banned_phrases = [
            "high quality", "best in class", "second to none",
            "state of the art", "world class", "industry leading",
        ]
        desc_lower = description.lower()
        for phrase in banned_phrases:
            if phrase in desc_lower:
                return False, f"Contains banned phrase: '{phrase}'"

        return True, "OK"

    @staticmethod
    def clean_title(raw: str) -> str:
        """Remove quotes, newlines, and leading/trailing whitespace."""
        cleaned = raw.strip().strip('"').strip("'")
        cleaned = cleaned.split('\n')[0]   # take first line only
        return cleaned

    @staticmethod
    def clean_description(raw: str) -> str:
        """Remove markdown artifacts and normalize whitespace."""
        cleaned = re.sub(r'\*\*(.+?)\*\*', r'\1', raw)   # remove **bold**
        cleaned = re.sub(r'\*(.+?)\*',     r'\1', cleaned)  # remove *italic*
        cleaned = re.sub(r'#{1,6}\s',      '',    cleaned)   # remove # headers
        cleaned = re.sub(r'\n{3,}',        '\n\n', cleaned)  # max 2 newlines
        return cleaned.strip()


# ─────────────────────────────────────────────────────────────────────────────
# GEMINI NANO SIMULATOR — for testing on your machine (no Android needed)
# ─────────────────────────────────────────────────────────────────────────────

class GeminiNanoSimulator:
    """
    Simulates Gemini Nano responses for testing on your local machine.
    Returns slightly improved versions of the template output.
    Used in test_generator.py only.
    """

    @staticmethod
    def generate_title(prompt: str, template_title: str) -> str:
        # Simulate: slightly rephrase the template title
        return template_title.replace(" — ", ": ").replace(" For Good", "")

    @staticmethod
    def generate_description(prompt: str, template_description: str) -> str:
        # Simulate: return template as-is (real Gemini would improve it)
        return template_description


# ─────────────────────────────────────────────────────────────────────────────
# GEMINI NANO ENGINE — PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────

class GeminiNanoEngine:
    """
    Tiered generation engine.

    Flow:
      1. Template engine generates base title + description
      2. Gemini Nano refines both (if available)
      3. Validator checks Gemini output
      4. If validation fails → keep template output
      5. Returns GeneratorOutput with generation_mode set accordingly

    The Android team integrates step 2 via method channel.
    On your machine, GeminiNanoSimulator is used for testing.
    """

    def __init__(self, use_simulator: bool = False):
        self._template_engine = TemplateEngine()
        self._prompt_builder  = PromptBuilder()
        self._validator       = OutputValidator()
        self._use_simulator   = use_simulator
        self._simulator       = GeminiNanoSimulator() if use_simulator else None

    def generate(self, inp: GeneratorInput) -> GeneratorOutput:
        tone = TONE_BY_MARKET.get(inp.market_type, DEFAULT_TONE)

        # Step 1 — Generate base content from templates
        template_result = self._template_engine.generate(inp)
        title           = template_result.product_title
        description     = template_result.product_description
        mode            = "template"

        # Step 2 — Build prompts (delivered to Android team)
        title_prompt = self._prompt_builder.build_title_prompt(inp)
        desc_prompt  = self._prompt_builder.build_description_prompt(inp, description)

        # Step 3 — Refine with Gemini Nano (simulator on local machine)
        if self._use_simulator and self._simulator:
            raw_title = self._simulator.generate_title(title_prompt, title)
            raw_desc  = self._simulator.generate_description(desc_prompt, description)
        else:
            # On Android: this is where the method channel call happens
            # The Flutter team calls AICore with title_prompt and desc_prompt
            # and passes results back here for validation
            # For now — use template output directly
            raw_title = title
            raw_desc  = description

        # Step 4 — Validate and clean Gemini output
        clean_title = self._validator.clean_title(raw_title)
        clean_desc  = self._validator.clean_description(raw_desc)

        title_valid, title_reason = self._validator.validate_title(clean_title, inp)
        desc_valid,  desc_reason  = self._validator.validate_description(clean_desc)

        if title_valid:
            title = clean_title
            mode  = "gemini_nano"
        else:
            print(f"[GeminiNano] Title validation failed: {title_reason} → using template")

        if desc_valid:
            description = clean_desc
            if mode == "gemini_nano":
                mode = "gemini_nano"
        else:
            print(f"[GeminiNano] Description validation failed: {desc_reason} → using template")
            if mode != "gemini_nano":
                mode = "template"

        return GeneratorOutput(
            product_title       = title,
            product_description = description,
            generation_mode     = mode,
            marketing_angle     = inp.marketing_angle,
            tone                = tone,
        )

    def get_prompts(self, inp: GeneratorInput) -> dict:
        """
        Returns the prompts for a given input.
        Used by the Android team to know exactly what to send to AICore.
        """
        template_result = self._template_engine.generate(inp)
        return {
            "title_prompt":       self._prompt_builder.build_title_prompt(inp),
            "description_prompt": self._prompt_builder.build_description_prompt(
                inp, template_result.product_description
            ),
        }
