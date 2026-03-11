"""
integration_test.py
Full end-to-end integration test — all 5 components.
Each layer runs in its own isolated subprocess to avoid import collisions.
Layer 1 + Layer 2 are mocked. Preprocessing + Layer 3 + Layer 4 run for real.

Usage:
    python integration_test.py
    python integration_test.py --verbose
"""

import sys
import os
import json
import subprocess
import argparse
import re
import traceback

BASE_DIR           = os.path.dirname(os.path.abspath(__file__))
PREPROCESSING_PATH = os.path.join(BASE_DIR, "preprocessing")
LAYER3_PATH        = os.path.join(BASE_DIR, "layer3_scoring")
LAYER4_PATH        = os.path.join(BASE_DIR, "layer4_generator")


# ─────────────────────────────────────────────────────────────────────────────
# SUBPROCESS RUNNERS
# ─────────────────────────────────────────────────────────────────────────────

def run_subprocess(script: str, label: str) -> dict:
    r = subprocess.run([sys.executable, "-c", script], capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(f"{label} failed:\n{r.stderr}")
    return json.loads(r.stdout.strip())


def run_preprocessing(dom: dict) -> dict:
    dom_json = json.dumps(dom)
    script = "\n".join([
        "import sys, json",
        f"sys.path.insert(0, r'{PREPROCESSING_PATH}')",
        "from preprocessor import Preprocessor",
        f"c = Preprocessor().process(json.loads({repr(dom_json)}))",
        "print(json.dumps({'image_url':c.image_url,'description':c.description,'supplier_price':c.supplier_price,'shipping_cost':c.shipping_cost,'order_proxy':c.order_proxy,'rating':c.rating,'product_title':c.product_title,'missing_fields':c.missing_fields,'warnings':c.warnings,'has_image':c.has_image,'has_description':c.has_description,'is_complete':c.is_complete}))",
    ])
    return run_subprocess(script, "Preprocessing")


def run_layer3(l1: dict, l2: dict, supplier_price: float,
               shipping: float, trend_score: float) -> dict:
    inp = json.dumps({
        "layer1": l1, "layer2": l2,
        "user_input": {"supplier_price": supplier_price,
                       "shipping_cost": shipping, "ad_budget_daily": 0.0},
        "trend_score": trend_score,
    })
    script = "\n".join([
        "import sys, json",
        f"sys.path.insert(0, r'{LAYER3_PATH}')",
        "from scorer import ScoringEngine",
        f"r = ScoringEngine().score(json.loads({repr(inp)}))",
        "print(json.dumps(r.to_dict()))",
    ])
    return run_subprocess(script, "Layer 3")


def run_layer4(l3: dict) -> dict:
    inp = json.dumps(l3)
    script = "\n".join([
        "import sys, json",
        f"sys.path.insert(0, r'{LAYER4_PATH}')",
        "from generator import ContentGenerator",
        f"r = ContentGenerator(gemini_nano_available=False).generate(json.loads({repr(inp)}))",
        "print(json.dumps({'product_title':r.product_title,'product_description':r.product_description,'generation_mode':r.generation_mode,'marketing_angle':r.marketing_angle}))",
    ])
    return run_subprocess(script, "Layer 4")


# ─────────────────────────────────────────────────────────────────────────────
# MOCK LAYER 1
# ─────────────────────────────────────────────────────────────────────────────

def mock_layer1(image_url: str) -> dict:
    url = (image_url or "").lower()
    if "beauty" in url or "mirror" in url:
        return {"category": "beauty",              "wow_score": 0.82, "tiktokability": 0.74, "market_type": "mass"}
    elif "fitness" in url or "band" in url:
        return {"category": "fitness_outdoor",     "wow_score": 0.61, "tiktokability": 0.66, "market_type": "niche"}
    elif "wallet" in url or "leather" in url:
        return {"category": "fashion_accessories", "wow_score": 0.70, "tiktokability": 0.58, "market_type": "premium"}
    elif "kitchen" in url or "jar" in url:
        return {"category": "home_kitchen",        "wow_score": 0.55, "tiktokability": 0.62, "market_type": "mass"}
    else:
        return {"category": "gadget",              "wow_score": 0.50, "tiktokability": 0.50, "market_type": "mass"}


# ─────────────────────────────────────────────────────────────────────────────
# MOCK LAYER 2
# ─────────────────────────────────────────────────────────────────────────────

def mock_layer2(description: str) -> dict:
    dl = description.lower()
    words = description.split()
    product_name = " ".join(words[:4]) if len(words) >= 4 else description[:40]

    features = []
    for m in re.finditer(r"\d+[x°%]?\s+\w+(?:\s+\w+)?", description):
        feat = m.group().strip()
        if len(feat.split()) <= 4 and feat not in features:
            features.append(feat)
    for kw in ["usb rechargeable", "wireless", "portable", "waterproof",
               "anti-snap", "adjustable", "rfid blocking", "one-touch"]:
        if kw in dl and kw not in features:
            features.append(kw)
    features = features[:5]

    audience = [w for w in ["women", "men", "athletes", "seniors",
                             "professionals", "travelers", "elderly"] if w in dl]

    problems = {"bad lighting": "bad lighting", "back pain": "back pain",
                "tight jar": "tight jar lids", "gym membership": "expensive gym membership",
                "struggle": "daily struggle"}
    problem = next((v for k, v in problems.items() if k in dl), "")
    usp = features[0] if features else product_name

    if any(w in dl for w in ["never", "stop", "fix", "solve", "struggle"]):
        angle = "problem_solution"
    elif any(w in dl for w in ["transform", "glow", "upgrade"]):
        angle = "transformation"
    elif any(w in dl for w in ["instant", "seconds", "easy", "one-touch"]):
        angle = "convenience"
    elif any(w in dl for w in ["serious", "real", "athlete", "pro"]):
        angle = "identity"
    else:
        angle = "value"

    audience_size = "niche" if any(w in dl for w in
        ["athlete", "professional", "serious", "enthusiast"]) else "mass"

    promises = {
        "problem_solution": "Solves " + (problem or "the problem") + " finally",
        "transformation":   "Transform with " + usp,
        "convenience":      usp + " in seconds",
        "identity":         "For people who need " + usp,
        "value":            "Get " + usp + " worth every penny",
    }

    # Simulate review sentiment based on description tone
    has_positive = any(w in dl for w in ["love", "perfect", "great", "amazing", "excellent"])
    has_negative = any(w in dl for w in ["broke", "cheap", "waste", "terrible", "bad"])
    if has_positive and not has_negative:
        rev_score, rev_label = 0.80, "Very Positive ⭐⭐⭐"
        praise, complaints   = ["great quality", "works as described"], []
    elif has_negative and not has_positive:
        rev_score, rev_label = 0.25, "Negative ❌"
        praise, complaints   = [], ["quality issues reported"]
    else:
        rev_score, rev_label = 0.60, "Positive ✅"
        praise, complaints   = ["decent quality"], []

    return {
        "product_name": product_name, "key_features": features,
        "target_audience": audience, "problem_solved": problem,
        "main_benefit": usp, "usp": usp,
        "main_promise": promises.get(angle, usp),
        "marketing_angle": angle, "audience_size": audience_size,
        # Review sentiment
        "review_sentiment_score": rev_score,
        "review_sentiment_label": rev_label,
        "customer_praise":        praise,
        "customer_complaints":    complaints,
        "review_count":           4,
    }


# ─────────────────────────────────────────────────────────────────────────────
# FULL PIPELINE
# ─────────────────────────────────────────────────────────────────────────────

def run_pipeline(dom: dict, trend_score: float = 0.6) -> dict:
    clean = run_preprocessing(dom)
    l1    = mock_layer1(clean["image_url"] or "")
    l2    = mock_layer2(clean["description"])
    l2_full = {**l2, **{k: l1[k] for k in ["category", "market_type"]}}
    supplier_price = clean["supplier_price"] or 5.0
    l3 = run_layer3(l1, l2_full, supplier_price, clean["shipping_cost"], trend_score)
    l4 = run_layer4(l3)
    return {"clean": clean, "l1": l1, "l2": l2, "l3": l3, "l4": l4}


# ─────────────────────────────────────────────────────────────────────────────
# TEST CASES
# ─────────────────────────────────────────────────────────────────────────────

TEST_CASES = [
    {
        "name": "Beauty — High Potential",
        "dom": {
            "image_url":     "//ae01.alicdn.com/kf/beauty_mirror.jpg",
            "description":   "Portable LED Makeup Mirror with 10x magnification and 360 degree rotation. USB rechargeable. Perfect for travel. Women love this. Never struggle with bad lighting again.",
            "price":         "US $4.50",
            "shipping":      "Free shipping",
            "order_count":   "10,000+ sold",
            "rating":        "4.7 out of 5",
            "product_title": "Portable LED Makeup Mirror",
        },
        "trend_score": 0.75,
    },
    {
        "name": "Fitness — Niche Product",
        "dom": {
            "image_url":     "//ae01.alicdn.com/kf/fitness_bands.jpg",
            "description":   "Resistance Band Set with 5 resistance levels. Anti-snap latex. Perfect for athletes and serious home gym enthusiasts.",
            "price":         "US $6.00",
            "shipping":      "$2.50",
            "order_count":   "3,200 sold",
            "rating":        "4.8 out of 5",
            "product_title": "Resistance Band Set Pro",
        },
        "trend_score": 0.55,
    },
    {
        "name": "Kitchen — Convenience",
        "dom": {
            "image_url":     "//ae01.alicdn.com/kf/kitchen_jar.jpg",
            "description":   "Electric Jar Opener opens any jar in 3 seconds with one-touch operation. Fits all jar sizes. Perfect for seniors.",
            "price":         "$12.99",
            "shipping":      "Free shipping",
            "order_count":   "8,500+ sold",
            "rating":        "4.6",
            "product_title": "Electric Jar Opener",
        },
        "trend_score": 0.50,
    },
    {
        "name": "Price Failed — Hybrid Mode",
        "dom": {
            "image_url":     "//ae01.alicdn.com/kf/leather_wallet.jpg",
            "description":   "Minimalist leather wallet with RFID blocking. Holds 12 cards. Genuine leather. Slim 6mm profile. Perfect for professionals.",
            "price":         "Contact seller",
            "shipping":      "Free",
            "order_count":   "500 orders",
            "rating":        "4.9",
            "product_title": "Minimalist Leather Wallet",
        },
        "trend_score": 0.45,
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# RUNNER
# ─────────────────────────────────────────────────────────────────────────────

def run_tests(verbose: bool = False):
    print("=" * 65)
    print("  End-to-End Integration Test — All 5 Components")
    print("  Preprocessing → L1 (mock) → L2 (mock) → L3 → L4")
    print("=" * 65)

    all_passed = True

    for i, case in enumerate(TEST_CASES, 1):
        sep = "─" * 65
        print(f"\n{sep}")
        print(f"  Test {i}/4 — {case['name']}")
        print(sep)

        try:
            r  = run_pipeline(case["dom"], case["trend_score"])
            c  = r["clean"]
            l1 = r["l1"]
            l2 = r["l2"]
            l3 = r["l3"]
            l4 = r["l4"]
            m  = l3["margin"]

            print(f"\n  [PREPROCESSING]")
            print(f"    image        : {'OK' if c['has_image'] else 'MISSING'}")
            print(f"    description  : {'OK' if c['has_description'] else 'MISSING'} ({len(c['description'].split())} words)")
            print(f"    price        : {'$' + str(c['supplier_price']) if c['supplier_price'] else 'MISSING - manual entry needed'}")
            print(f"    shipping     : ${c['shipping_cost']}")
            print(f"    orders       : {c['order_proxy']:,}")
            print(f"    rating       : {c['rating']}")
            if c["warnings"]:
                for w in c["warnings"]:
                    print(f"    WARNING: {w}")

            print(f"\n  [LAYER 1]  (mock)")
            print(f"    category={l1['category']}  wow={l1['wow_score']}  tiktok={l1['tiktokability']}  market={l1['market_type']}")

            print(f"\n  [LAYER 2]  (mock)")
            print(f"    usp      = {l2['usp']}")
            print(f"    angle    = {l2['marketing_angle']}")
            print(f"    features = {l2['key_features'][:3]}")
            print(f"    problem  = {l2['problem_solved'] or '(none detected)'}")

            print(f"\n  [LAYER 3 — Scoring Engine]")
            print(f"    viral score  : {l3['viral_score']}/10  {l3['viral_label']}")
            print(f"    competition  : {l3['competition_risk']}")
            print(f"    margin       : {l3['margin_potential']} ({m['gross_margin_pct']})")
            print(f"    sell price   : ${m['recommended_price']}")
            print(f"    seasonality  : {l3['seasonality_label']} ({l3['seasonality_score']})")
            print(f"    reviews      : {l3['review_sentiment_label']} ({l3.get('review_count',0)} reviews)")
            if l3.get('customer_complaints'):
                print(f"    complaints   : {', '.join(l3['customer_complaints'][:2])}")
            print(f"    profit/unit  : ${m['profit_per_unit']}")
            print(f"    ROAS target  : {m['roas_target']}x")

            print(f"\n  [LAYER 4 — Generator]  ({l4['generation_mode']})")
            print(f"    TITLE  : {l4['product_title']}")
            if verbose:
                print(f"    DESCRIPTION:")
                for line in l4["product_description"].split("\n"):
                    if line.strip():
                        print(f"      {line}")
            else:
                first = next((ln for ln in l4["product_description"].split("\n") if ln.strip()), "")
                print(f"    DESC   : {first[:70]}")

            checks = [
                (l1["category"] in ["gadget","beauty","home_kitchen",
                  "fashion_accessories","pet_kids","fitness_outdoor"], "L1 category valid"),
                (0.0 <= l1["wow_score"] <= 1.0,          "L1 wow in range [0,1]"),
                (bool(l2["usp"]),                         "L2 USP extracted"),
                (bool(l2["marketing_angle"]),             "L2 angle classified"),
                ("review_sentiment_score" in l2,          "L2 review sentiment present"),
                (0.0 <= l2["review_sentiment_score"] <= 1.0, "L2 review sentiment in range [0,1]"),
                (0.0 <= l3["viral_score"] <= 10.0,        "L3 viral score in range"),
                (l3["competition_risk"] in ["Low","Medium","High"], "L3 risk valid"),
                (m["gross_margin"] > 0,                   "L3 margin positive"),
                ("seasonality_score" in l3,               "L3 seasonality present"),
                (0.0 <= l3["seasonality_score"] <= 1.0,   "L3 seasonality score in range [0,1]"),
                (bool(l3["seasonality_advice"]),          "L3 seasonality advice generated"),
                ("review_sentiment_score" in l3,          "L3 review sentiment passed through"),
                (len(l4["product_title"]) > 0,            "L4 title generated"),
                (len(l4["product_description"]) > 0,      "L4 description generated"),
            ]

            print(f"\n  [CHECKS]")
            case_ok = True
            for ok, name in checks:
                mark = "PASS" if ok else "FAIL"
                print(f"    [{mark}] {name}")
                if not ok:
                    case_ok    = False
                    all_passed = False

            result_str = "PASS" if case_ok else "FAIL"
            print(f"\n  >>> {result_str}")

        except Exception as e:
            print(f"\n  ERROR: {e}")
            traceback.print_exc()
            all_passed = False

    eq = "=" * 65
    print(f"\n{eq}")
    if all_passed:
        print("  All 4 integration tests passed.")
        print("  Full pipeline operational end-to-end.")
        print("  Next: replace mock_layer1/2 with real TFLite inference.")
    else:
        print("  Some tests failed.")
    print(eq)


def run_batch_test():
    """
    Integration test for BatchPipeline.
    Verifies batch scoring, ranking, title fallback, and error isolation.
    """
    sys.path.insert(0, os.path.dirname(__file__))
    from batch_pipeline import BatchPipeline, BatchResult

    eq = "=" * 65
    print(f"\n{eq}")
    print("  BATCH PIPELINE INTEGRATION TEST")
    print(eq)

    payload = {
        "source_url": "https://aliexpress.com/category/massagers",
        "page_type":  "category",
        "products": [
            {   # full description — full Layer 2
                "product_title": "Portable LED Makeup Mirror 10x Magnification",
                "image_url":     "//ae01.alicdn.com/kf/led_mirror.jpg",
                "price":         "US $4.50",
                "shipping":      "Free shipping",
                "order_count":   "10,000+ sold",
                "rating":        "4.7 out of 5",
                "description":   "Portable LED Makeup Mirror with 10x magnification. USB rechargeable. Perfect for travel. Never struggle with bad lighting again.",
            },
            {   # title only — title fallback active
                "product_title": "Smart Electric Neck Massager Wireless Pulse Pain Relief",
                "image_url":     "//ae01.alicdn.com/kf/massager.jpg",
                "price":         "US $12.50",
                "shipping":      "Free shipping",
                "order_count":   "8,500+ sold",
                "rating":        "4.6 out of 5",
                "description":   "",
            },
            {   # missing price — supplier_price defaults to 5.0
                "product_title": "Resistance Band Set Anti-Snap 5 Levels",
                "image_url":     "//ae01.alicdn.com/kf/bands.jpg",
                "price":         "",
                "shipping":      "Free shipping",
                "order_count":   "3,200+ sold",
                "rating":        "4.3 out of 5",
                "description":   "",
            },
            {   # bad data — should be processed without crashing batch
                "product_title": "Unknown Product",
                "image_url":     "",
                "price":         "",
                "shipping":      "",
                "order_count":   "",
                "rating":        "",
                "description":   "",
            },
            {   # French title — multilingual
                "product_title": "Masseur Cervical Intelligent Sans Fil Soulagement Douleur",
                "image_url":     "//ae01.alicdn.com/kf/masseur_fr.jpg",
                "price":         "12,50 EUR",
                "shipping":      "Livraison gratuite",
                "order_count":   "5 000+ vendus",
                "rating":        "4.5 sur 5",
                "description":   "",
            },
        ]
    }

    passed = True
    result = BatchPipeline().run(payload)

    checks = [
        (result.total_input == 5,                                 "Batch: all 5 products processed"),
        (result.error_count == 0,                                 "Batch: zero pipeline errors"),
        (len(result.winners) + len(result.worth_watching) > 0,   "Batch: at least 1 ranked result"),
        (result.processing_ms > 0,                               "Batch: processing time recorded"),
        (result.source_url == payload["source_url"],             "Batch: source_url preserved"),

        # Ranking checks
        (all(p.viral_score >= 7.0 for p in result.winners),      "Ranking: all winners >= 7.0 viral"),
        (all(p.viral_score >= 4.5 for p in result.worth_watching),"Ranking: watchlist >= 4.5 viral"),
        (all(p.rank > 0 for p in result.winners),                "Ranking: winners have rank > 0"),

        # Title fallback check
        (any(p.description_source == "title_fallback"
             for p in result.winners + result.worth_watching + result.skipped),
                                                                  "Fallback: title_fallback used when description empty"),
        (any(p.description_source == "full_description"
             for p in result.winners + result.worth_watching + result.skipped),
                                                                  "Fallback: full_description used when available"),

        # Scores in valid range
        (all(0.0 <= p.viral_score <= 10.0
             for p in result.winners + result.worth_watching + result.skipped),
                                                                  "Scores: all viral_score in [0, 10]"),
        (all(p.competition_risk in ["Low","Medium","High"]
             for p in result.winners + result.worth_watching + result.skipped),
                                                                  "Scores: competition_risk valid values"),
        (all(p.seasonality_label != ""
             for p in result.winners + result.worth_watching + result.skipped),
                                                                  "Scores: seasonality_label present"),
    ]

    print(f"\n  [CHECKS]")
    for ok, name in checks:
        mark = "PASS" if ok else "FAIL"
        print(f"    [{mark}] {name}")
        if not ok:
            passed = False

    print(f"\n  Winners        : {len(result.winners)}")
    print(f"  Worth Watching : {len(result.worth_watching)}")
    print(f"  Skipped        : {result.skipped_count}")
    print(f"  Errors         : {result.error_count}")
    print(f"  Time           : {result.processing_ms}ms")

    result_str = "PASS" if passed else "FAIL"
    print(f"\n  >>> {result_str}")
    print(eq)
    return passed


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--verbose", action="store_true", help="Show full descriptions")
    parser.add_argument("--batch",   action="store_true", help="Run batch pipeline test")
    args = parser.parse_args()
    if args.batch:
        run_batch_test()
    else:
        run_tests(verbose=args.verbose)
