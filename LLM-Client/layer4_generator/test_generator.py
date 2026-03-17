# layer4_generator/test_generator.py
# ─────────────────────────────────────────────────────────────────────────────
# Test Layer 4 end to end using mock Layer 3 output.
#
# Usage:
#   python test_generator.py                  # template engine only
#   python test_generator.py --gemini         # with Gemini Nano simulator
#   python test_generator.py --prompts        # print Gemini prompts
# ─────────────────────────────────────────────────────────────────────────────

import argparse
from generator import ContentGenerator

# ─────────────────────────────────────────────────────────────────────────────
# MOCK LAYER 3 OUTPUTS — one per marketing angle
# ─────────────────────────────────────────────────────────────────────────────

MOCK_CASES = [
    {
        "name": "Beauty — Transformation",
        "layer3_output": {
            "product_name":    "Portable LED Makeup Mirror",
            "usp":             "10x magnification",
            "main_promise":    "Transform with 10x magnification",
            "marketing_angle": "transformation",
            "key_features":    ["10x magnification", "360° rotation", "USB rechargeable"],
            "category":        "beauty",
            "market_type":     "mass",
            "problem_solved":  "bad lighting when applying makeup",
            "target_audience": ["women", "travelers"],
        }
    },
    {
        "name": "Gadget — Problem Solution",
        "layer3_output": {
            "product_name":    "Posture Corrector Belt",
            "usp":             "adjustable lumbar support",
            "main_promise":    "Solves back pain — finally",
            "marketing_angle": "problem_solution",
            "key_features":    ["adjustable lumbar support", "breathable mesh", "discreet under clothes"],
            "category":        "fitness_outdoor",
            "market_type":     "mass",
            "problem_solved":  "chronic back pain from desk work",
            "target_audience": ["office workers", "remote workers"],
        }
    },
    {
        "name": "Kitchen — Convenience",
        "layer3_output": {
            "product_name":    "Electric Jar Opener",
            "usp":             "opens any jar in 3 seconds",
            "main_promise":    "opens any jar in 3 seconds",
            "marketing_angle": "convenience",
            "key_features":    ["opens any jar in 3 seconds", "one-touch operation", "fits all jar sizes"],
            "category":        "home_kitchen",
            "market_type":     "mass",
            "problem_solved":  "struggling with tight jar lids",
            "target_audience": ["seniors", "people with arthritis"],
        }
    },
    {
        "name": "Fitness — Identity (Niche)",
        "layer3_output": {
            "product_name":    "Resistance Band Set Pro",
            "usp":             "5 resistance levels",
            "main_promise":    "For people who need 5 resistance levels",
            "marketing_angle": "identity",
            "key_features":    ["5 resistance levels", "anti-snap latex", "door anchor included"],
            "category":        "fitness_outdoor",
            "market_type":     "niche",
            "problem_solved":  "expensive gym membership",
            "target_audience": ["athletes", "home gym enthusiasts"],
        }
    },
    {
        "name": "Fashion — Social Proof",
        "layer3_output": {
            "product_name":    "Minimalist Leather Wallet",
            "usp":             "genuine leather, holds 12 cards",
            "main_promise":    "The wallet everyone is buying",
            "marketing_angle": "social_proof",
            "key_features":    ["genuine leather", "holds 12 cards", "RFID blocking", "slim 6mm profile"],
            "category":        "fashion_accessories",
            "market_type":     "premium",
            "problem_solved":  "bulky uncomfortable wallet",
            "target_audience": ["men", "professionals"],
        }
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# TEST RUNNER
# ─────────────────────────────────────────────────────────────────────────────

def run_tests(use_gemini: bool = False, show_prompts: bool = False):
    generator = ContentGenerator(
        gemini_nano_available = use_gemini,
        use_simulator         = use_gemini,
    )

    mode_label = "GEMINI NANO (simulator)" if use_gemini else "TEMPLATE ENGINE"

    print("=" * 65)
    print(f"  Layer 4 Generator Test — {mode_label}")
    print("=" * 65)

    for case in MOCK_CASES:
        print(f"\n── {case['name']} {'─' * (50 - len(case['name']))}")

        result = generator.generate(case["layer3_output"])

        print(f"\n  TITLE [{result.generation_mode}]:")
        print(f"  {result.product_title}")

        print(f"\n  DESCRIPTION [{result.generation_mode}]:")
        for line in result.product_description.split('\n'):
            print(f"  {line}")

        if show_prompts:
            prompts = generator.get_prompts(case["layer3_output"])
            print(f"\n  GEMINI TITLE PROMPT:")
            for line in prompts["title_prompt"].split('\n'):
                print(f"    {line}")
            print(f"\n  GEMINI DESCRIPTION PROMPT (first 5 lines):")
            for line in prompts["description_prompt"].split('\n')[:5]:
                print(f"    {line}")
            print("    ...")

    print("\n" + "=" * 65)
    print("  All tests complete.")
    print("=" * 65)


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--gemini",  action="store_true", help="Use Gemini Nano simulator")
    parser.add_argument("--prompts", action="store_true", help="Print Gemini prompts")
    args = parser.parse_args()

    run_tests(use_gemini=args.gemini, show_prompts=args.prompts)
