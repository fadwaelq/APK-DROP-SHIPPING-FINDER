# layer4_generator/constants.py
# ─────────────────────────────────────────────────────────────────────────────
# All templates, prompt configs, and generation constants for Layer 4.
# Change copy strategy here — nowhere else.
# ─────────────────────────────────────────────────────────────────────────────


# ─────────────────────────────────────────────────────────────────────────────
# PRODUCT TITLE TEMPLATES
# One template per marketing angle (7 total)
# Placeholders: {product}, {usp}, {problem}, {audience}, {benefit}
# ─────────────────────────────────────────────────────────────────────────────

TITLE_TEMPLATES = {
    "problem_solution": [
        "Stop {problem} — {product} Finally Works",
        "The {product} That Fixes {problem} For Good",
        "No More {problem} — {usp} Changes Everything",
    ],
    "transformation": [
        "{product} — {usp} That Transforms Your Routine",
        "Upgrade Your Life With {usp}",
        "The {product} Behind Every Glow Up",
    ],
    "social_proof": [
        "Why Everyone Is Buying This {product}",
        "The {product} That Sold 10,000+ Units — Here's Why",
        "Trending Now: {product} With {usp}",
    ],
    "curiosity": [
        "You Won't Believe What This {product} Can Do",
        "The Secret Behind {usp} — Finally Revealed",
        "This {product} Is Not What You Think",
    ],
    "convenience": [
        "{usp} In Seconds — {product} Makes It Easy",
        "The {product} That Does It All For You",
        "Instant Results: {product} With {usp}",
    ],
    "identity": [
        "{product} — For People Who Take {audience} Seriously",
        "Serious About {audience}? You Need {usp}",
        "The {product} Built For Real {audience} Lovers",
    ],
    "value": [
        "{product} — Replaces 5 Products In One",
        "Best Value: {product} With {usp}",
        "{product} — Worth Every Penny",
    ],
}

# ─────────────────────────────────────────────────────────────────────────────
# PRODUCT DESCRIPTION TEMPLATES
# Structure: Hook → Problem → Solution → Features → CTA
# One template per marketing angle
# ─────────────────────────────────────────────────────────────────────────────

DESCRIPTION_TEMPLATES = {
    "problem_solution": """
{hook}

Tired of {problem}? You're not alone. Most people deal with this every day — until they find {product}.

{product} was designed to solve exactly this. With {usp}, it tackles {problem} directly so you never have to deal with it again.

What makes it different:
{features_list}

{cta}
""",
    "transformation": """
{hook}

Imagine a version of yourself that {benefit}. That's exactly what {product} delivers.

Powered by {usp}, {product} gives you professional-level results from the comfort of your home.

What you get:
{features_list}

{cta}
""",
    "social_proof": """
{hook}

Thousands of people have already discovered {product} — and they can't stop talking about it.

The secret? {usp}. It's the one feature that makes {product} unlike anything else on the market.

Here's what's inside:
{features_list}

{cta}
""",
    "curiosity": """
{hook}

Most people have never seen anything like {product}. And once you do, you'll wonder how you ever lived without it.

The key is {usp} — a feature so effective, it changes how you think about {problem}.

Discover what's inside:
{features_list}

{cta}
""",
    "convenience": """
{hook}

What if {problem} took less than 60 seconds to solve? With {product}, it does.

{usp} means zero effort, instant results. No learning curve. No complicated setup. Just results.

Everything included:
{features_list}

{cta}
""",
    "identity": """
{hook}

This isn't for everyone. {product} was built for people who take {audience} seriously.

{usp} gives you the edge that separates casual from committed. If you know, you know.

Built-in advantages:
{features_list}

{cta}
""",
    "value": """
{hook}

Why buy 5 products when {product} replaces them all?

With {usp}, you get everything you need in one — at a fraction of the cost. Smart buyers already know.

Everything you get:
{features_list}

{cta}
""",
}

# ─────────────────────────────────────────────────────────────────────────────
# HOOK TEMPLATES — opening line per angle
# ─────────────────────────────────────────────────────────────────────────────

HOOK_TEMPLATES = {
    "problem_solution": "⚡ Finally — a real solution to {problem}.",
    "transformation":   "✨ Your routine is about to change forever.",
    "social_proof":     "🔥 Everyone is switching to {product} — here's why.",
    "curiosity":        "👀 You've never seen a {product} like this before.",
    "convenience":      "⏱️ {problem} solved in under 60 seconds.",
    "identity":         "💪 Built for people who don't settle.",
    "value":            "💰 Stop overpaying. One product. Everything you need.",
}

# ─────────────────────────────────────────────────────────────────────────────
# CTA TEMPLATES — call to action per angle
# ─────────────────────────────────────────────────────────────────────────────

CTA_TEMPLATES = {
    "problem_solution": "✅ Order today and solve {problem} for good.",
    "transformation":   "✅ Start your transformation — order now.",
    "social_proof":     "✅ Join thousands of happy customers — get yours today.",
    "curiosity":        "✅ See it for yourself — limited stock available.",
    "convenience":      "✅ Make your life easier — order now.",
    "identity":         "✅ Built for you — get {product} today.",
    "value":            "✅ Best value on the market — grab yours now.",
}

# ─────────────────────────────────────────────────────────────────────────────
# GEMINI NANO PROMPTS
# Used when device supports Gemini Nano (Android 14+)
# Template engine output is passed as context — Gemini refines it
# ─────────────────────────────────────────────────────────────────────────────

GEMINI_TITLE_PROMPT = """
You are a dropshipping product copywriter. 
Generate ONE compelling product title for the following product.

Product: {product_name}
USP: {usp}
Marketing angle: {marketing_angle}
Target audience: {audience}
Problem solved: {problem}

Rules:
- Maximum 80 characters
- No emojis
- No ALL CAPS
- Must include the USP
- Tone: {tone}

Return the title only. No explanation.
"""

GEMINI_DESCRIPTION_PROMPT = """
You are a dropshipping product copywriter.
Improve the following product description to make it more compelling and natural.

Original description:
{template_output}

Product details:
- Product: {product_name}
- USP: {usp}  
- Marketing angle: {marketing_angle}
- Key features: {features}
- Problem solved: {problem}

Rules:
- Keep the same structure (hook, problem, solution, features, CTA)
- Maximum 200 words
- Natural, conversational tone
- No generic filler phrases like "high quality" or "best in class"
- Tone: {tone}

Return the improved description only. No explanation.
"""

# ─────────────────────────────────────────────────────────────────────────────
# TONE BY MARKET TYPE
# ─────────────────────────────────────────────────────────────────────────────

TONE_BY_MARKET = {
    "mass":    "friendly, casual, broad appeal",
    "niche":   "specific, knowledgeable, speaks to enthusiasts",
    "premium": "sophisticated, confident, quality-focused",
}

# ─────────────────────────────────────────────────────────────────────────────
# TITLE SELECTION STRATEGY
# Which template index to use — rotated to avoid repetition
# ─────────────────────────────────────────────────────────────────────────────

DEFAULT_TITLE_TEMPLATE_INDEX = 0   # always use first template by default
