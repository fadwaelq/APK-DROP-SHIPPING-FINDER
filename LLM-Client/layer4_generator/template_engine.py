# layer4_generator/template_engine.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 4 — Template Engine
# ─────────────────────────────────────────────────────────────────────────────
# Generates product title and description using angle-specific templates.
# Works on ALL devices, zero dependencies, zero latency.
# This is the fallback when Gemini Nano is not available.
# ─────────────────────────────────────────────────────────────────────────────

import re
from models import GeneratorInput, GeneratorOutput
from constants import (
    TITLE_TEMPLATES, DESCRIPTION_TEMPLATES,
    HOOK_TEMPLATES, CTA_TEMPLATES,
    TONE_BY_MARKET, DEFAULT_TITLE_TEMPLATE_INDEX,
)


# ─────────────────────────────────────────────────────────────────────────────
# SLOT FILLER
# ─────────────────────────────────────────────────────────────────────────────

def _build_slots(inp: GeneratorInput) -> dict:
    """
    Build the slot dictionary used to fill all templates.
    Every placeholder used in constants.py must have a value here.
    """
    audience_str = (
        inp.target_audience[0]
        if inp.target_audience
        else inp.category.replace("_", " ")
    )

    features_list = "\n".join(
        f"• {feature}" for feature in inp.key_features
    ) if inp.key_features else f"• {inp.usp}"

    return {
        "product":       inp.product_name  or "this product",
        "usp":           inp.usp           or inp.main_promise,
        "problem":       inp.problem_solved or "the problem",
        "audience":      audience_str,
        "benefit":       inp.main_promise  or inp.usp,
        "features_list": features_list,
        "hook":          "",   # filled separately below
        "cta":           "",   # filled separately below
    }


def _fill_template(template: str, slots: dict) -> str:
    """
    Fill a template string with slot values.
    Strips leftover {placeholders} if a slot value is missing.
    """
    result = template
    for key, value in slots.items():
        result = result.replace("{" + key + "}", str(value))

    # Remove any unfilled placeholders
    result = re.sub(r'\{[^}]+\}', '', result)

    # Clean up extra whitespace
    result = re.sub(r'\n{3,}', '\n\n', result).strip()
    return result


# ─────────────────────────────────────────────────────────────────────────────
# TITLE GENERATOR
# ─────────────────────────────────────────────────────────────────────────────

def generate_title(
    inp: GeneratorInput,
    template_index: int = DEFAULT_TITLE_TEMPLATE_INDEX,
) -> str:
    """
    Generate a product title using the angle-specific template.

    Args:
        inp:            GeneratorInput from Layer 3
        template_index: which title variant to use (0, 1, or 2)
    """
    angle     = inp.marketing_angle
    templates = TITLE_TEMPLATES.get(angle, TITLE_TEMPLATES["convenience"])

    # Clamp index to available templates
    index    = template_index % len(templates)
    template = templates[index]

    slots = _build_slots(inp)
    title = _fill_template(template, slots)

    # Enforce 80 char limit — truncate at last word boundary
    if len(title) > 80:
        title = title[:77].rsplit(' ', 1)[0] + "..."

    return title


# ─────────────────────────────────────────────────────────────────────────────
# DESCRIPTION GENERATOR
# ─────────────────────────────────────────────────────────────────────────────

def generate_description(inp: GeneratorInput) -> str:
    """
    Generate a product description using the angle-specific template.
    Structure: Hook → Problem/Context → Solution → Features → CTA
    """
    angle    = inp.marketing_angle
    template = DESCRIPTION_TEMPLATES.get(angle, DESCRIPTION_TEMPLATES["convenience"])

    slots = _build_slots(inp)

    # Fill hook and CTA separately
    hook_template = HOOK_TEMPLATES.get(angle, "")
    cta_template  = CTA_TEMPLATES.get(angle, "✅ Order now.")

    slots["hook"] = _fill_template(hook_template, slots)
    slots["cta"]  = _fill_template(cta_template,  slots)

    description = _fill_template(template, slots)
    return description


# ─────────────────────────────────────────────────────────────────────────────
# TEMPLATE ENGINE — PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────

class TemplateEngine:
    """
    Generates product title and description from templates.
    No dependencies, no model loading, instant results.
    """

    def generate(self, inp: GeneratorInput) -> GeneratorOutput:
        title       = generate_title(inp)
        description = generate_description(inp)
        tone        = TONE_BY_MARKET.get(inp.market_type, "friendly, casual")

        return GeneratorOutput(
            product_title       = title,
            product_description = description,
            generation_mode     = "template",
            marketing_angle     = inp.marketing_angle,
            tone                = tone,
        )
