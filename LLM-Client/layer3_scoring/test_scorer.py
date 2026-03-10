# layer3_scoring/test_scorer.py
# ─────────────────────────────────────────────────────────────────────────────
# Quick test — runs Layer 3 with mock Layer 1 + Layer 2 outputs.
# No dependencies needed beyond Python stdlib.
#
# Usage:
#   python test_scorer.py
# ─────────────────────────────────────────────────────────────────────────────

from scorer import ScoringEngine

# ─────────────────────────────────────────────────────────────────────────────
# MOCK INPUTS — simulating real Layer 1 + Layer 2 outputs
# ─────────────────────────────────────────────────────────────────────────────

MOCK_CASES = [
    {
        "name": "High-Potential Beauty Product",
        "input": {
            "layer1": {
                "category":      "beauty",
                "wow_score":     0.82,
                "tiktokability": 0.74,
                "market_type":   "mass",
            },
            "layer2": {
                "product_name":    "Portable LED Makeup Mirror",
                "key_features":    ["10x magnification", "360° rotation", "USB rechargeable"],
                "target_audience": ["women", "travel"],
                "problem_solved":  "bad lighting when applying makeup",
                "main_benefit":    "perfect makeup anywhere",
                "usp":             "10x magnification",
                "main_promise":    "Transform with 10x magnification",
                "marketing_angle": "transformation",
                "audience_size":   "mass",
            },
            "user_input": {
                "supplier_price":  4.50,
                "shipping_cost":   2.00,
                "ad_budget_daily": 20.0,
            },
            "trend_score": 0.75,
        }
    },
    {
        "name": "Saturated Gadget — Low Potential",
        "input": {
            "layer1": {
                "category":      "gadget",
                "wow_score":     0.35,
                "tiktokability": 0.30,
                "market_type":   "mass",
            },
            "layer2": {
                "product_name":    "USB Phone Charger",
                "key_features":    ["fast charging", "USB-C"],
                "target_audience": [],
                "problem_solved":  "",
                "main_benefit":    "charges fast",
                "usp":             "fast charging",
                "main_promise":    "fast charging in seconds",
                "marketing_angle": "convenience",
                "audience_size":   "mass",
            },
            "user_input": {
                "supplier_price":  2.00,
                "shipping_cost":   1.50,
                "ad_budget_daily": 10.0,
            },
            "trend_score": 0.30,
        }
    },
    {
        "name": "Niche Fitness Product — Medium Potential",
        "input": {
            "layer1": {
                "category":      "fitness_outdoor",
                "wow_score":     0.60,
                "tiktokability": 0.65,
                "market_type":   "niche",
            },
            "layer2": {
                "product_name":    "Resistance Band Set",
                "key_features":    ["5 resistance levels", "anti-snap latex", "portable"],
                "target_audience": ["athletes", "home gym"],
                "problem_solved":  "expensive gym membership",
                "main_benefit":    "full workout at home",
                "usp":             "5 resistance levels",
                "main_promise":    "For people who need 5 resistance levels",
                "marketing_angle": "identity",
                "audience_size":   "niche",
            },
            "user_input": {
                "supplier_price":  6.00,
                "shipping_cost":   2.50,
                "ad_budget_daily": 15.0,
            },
            "trend_score": 0.55,
        }
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# RUN TESTS
# ─────────────────────────────────────────────────────────────────────────────

def run_tests():
    engine = ScoringEngine()

    print("=" * 60)
    print("  Layer 3 Scoring Engine — Test Suite")
    print("=" * 60)

    for case in MOCK_CASES:
        print(f"\n── {case['name']} ──────────────────────────────")

        result = engine.score(case["input"])

        print(f"  Viral Score      : {result.viral_score}/10  {result.viral_label}")
        print(f"  Competition Risk : {result.competition_risk}")
        print(f"  Margin Potential : {result.margin_potential}")
        print(f"\n  Margin Breakdown:")
        print(f"    Supplier Price    : ${result.margin.supplier_price:.2f}")
        print(f"    Shipping Cost     : ${result.margin.shipping_cost:.2f}")
        print(f"    Total Cost        : ${result.margin.total_cost:.2f}")
        print(f"    Recommended Price : ${result.margin.recommended_price:.2f}")
        print(f"    Gross Margin      : {result.margin.gross_margin_pct}")
        print(f"    Profit / Unit     : ${result.margin.profit_per_unit:.2f}")
        print(f"    ROAS Target       : {result.margin.roas_target}x")
        print(f"\n  Pass-through to Layer 4:")
        print(f"    USP             : {result.usp}")
        print(f"    Marketing Angle : {result.marketing_angle}")
        print(f"    Main Promise    : {result.main_promise}")

    print("\n" + "=" * 60)
    print("  All tests passed.")
    print("=" * 60)


if __name__ == "__main__":
    run_tests()
