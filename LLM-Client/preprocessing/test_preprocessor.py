# preprocessing/test_preprocessor.py
# ─────────────────────────────────────────────────────────────────────────────
# Test the full preprocessing pipeline with realistic DOM data.
# Run right now — no dependencies needed beyond Python stdlib.
#
# Usage:
#   python test_preprocessor.py
# ─────────────────────────────────────────────────────────────────────────────

from preprocessor import Preprocessor

# ─────────────────────────────────────────────────────────────────────────────
# TEST CASES — realistic DOM extraction scenarios
# ─────────────────────────────────────────────────────────────────────────────

TEST_CASES = [
    {
        "name": "Clean AliExpress Product — All Fields Present",
        "input": {
            "image_url":   "//ae01.alicdn.com/kf/product_mirror_01.jpg",
            "description": "Portable LED Makeup Mirror with 10x magnification and 360 degree rotation. USB rechargeable. Perfect for travel. Women love this for hotel rooms. Never struggle with bad lighting again. Great for applying makeup anywhere.",
            "price":       "US $4.50",
            "shipping":    "Free shipping",
            "order_count": "10,000+ sold",
            "rating":      "4.7 out of 5",
            "product_title": "Portable LED Makeup Mirror 10x Magnification",
        },
        "expect_complete": True,
    },
    {
        "name": "Mixed Chinese/English Description",
        "input": {
            "image_url":   "https://ae01.alicdn.com/kf/product_02.jpg",
            "description": "高品质便携式LED化妆镜 Portable LED Makeup Mirror with 10x magnification. 360度旋转 USB rechargeable. Perfect for travel and home use. 永远不用担心光线问题 Never struggle with bad lighting again.",
            "price":       "$4.50",
            "shipping":    "$2.00 shipping",
            "order_count": "5k+ orders",
            "rating":      "4.5",
        },
        "expect_complete": True,
    },
    {
        "name": "Messy DOM — European Format + Range Price",
        "input": {
            "image_url":   "https://ae01.alicdn.com/kf/product_03.jpg",
            "description": "Resistance Band Set with 5 resistance levels. Anti-snap latex material. Perfect for home gym workouts. Includes door anchor. Great for athletes and beginners.",
            "price":       "6,00 € - 8,50 €",
            "shipping":    "Livraison gratuite",
            "order_count": "1.2m vendus",
            "rating":      "4,8/5",
        },
        "expect_complete": True,
    },
    {
        "name": "Price Extraction Failed — Manual Entry Required",
        "input": {
            "image_url":   "https://shopify.com/products/wallet.jpg",
            "description": "Minimalist leather wallet with RFID blocking. Holds 12 cards. Genuine leather. Slim 6mm profile. Perfect for professionals who want a clean, organized wallet.",
            "price":       "Contact seller for price",
            "shipping":    "Free",
            "order_count": "500 orders",
            "rating":      "4.9 out of 5",
        },
        "expect_complete": False,
    },
    {
        "name": "Dirty DOM — HTML Entities + Emojis + Truncation",
        "input": {
            "image_url":   "//ae01.alicdn.com/kf/product_05.jpg",
            "description": "⚡ Electric Jar Opener &amp; Can Opener 🔧 Opens any jar in 3 seconds! One-touch operation. Fits all jar sizes. Perfect for elderly &amp; people with arthritis. Free shipping on orders &gt; $20... read more",
            "price":       "US $12.99",
            "shipping":    "Free shipping",
            "order_count": "8,500+ sold",
            "rating":      "★★★★☆",
        },
        "expect_complete": True,
    },
    {
        "name": "Missing Image — Layer 1 Cannot Run",
        "input": {
            "image_url":   None,
            "description": "Posture corrector belt with adjustable lumbar support. Breathable mesh material. Discreet under clothes. Helps with chronic back pain from desk work.",
            "price":       "US $9.99",
            "shipping":    "$1.50",
            "order_count": "3,200 sold",
            "rating":      "4.6",
        },
        "expect_complete": False,
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# TEST RUNNER
# ─────────────────────────────────────────────────────────────────────────────

def run_tests():
    preprocessor = Preprocessor()

    print("=" * 62)
    print("  Preprocessing Pipeline — Test Suite")
    print("=" * 62)

    all_passed = True

    for case in TEST_CASES:
        print(f"\n── {case['name']} {'─' * max(1, 55 - len(case['name']))}")

        result = preprocessor.process(case["input"])
        status = preprocessor.get_pipeline_status(result)

        # ── Print Results ──────────────────────────────────────────
        print(f"  image_url        : {result.image_url or 'None'}")
        print(f"  description      : {result.description[:60]}..." if result.description else "  description      : [empty]")
        print(f"  supplier_price   : {result.supplier_price}")
        print(f"  shipping_cost    : {result.shipping_cost}")
        print(f"  order_proxy      : {result.order_proxy}")
        print(f"  rating           : {result.rating}")

        print(f"\n  Pipeline Status:")
        print(f"    Layer 1 ready  : {status['layer1_ready']}")
        print(f"    Layer 2 ready  : {status['layer2_ready']}")
        print(f"    Layer 3 ready  : {status['layer3_ready']}")
        print(f"    Complete       : {status['is_complete']}")

        if result.missing_fields:
            print(f"    Missing        : {result.missing_fields}")
        if result.warnings:
            print(f"    Warnings       : {result.warnings}")

        # ── Validate Expectation ───────────────────────────────────
        passed = result.is_complete == case["expect_complete"]
        mark   = "✓ PASS" if passed else "✗ FAIL"
        print(f"\n  Expected complete={case['expect_complete']} → {mark}")

        if not passed:
            all_passed = False

    print("\n" + "=" * 62)
    if all_passed:
        print("  All tests passed ✓")
    else:
        print("  Some tests failed ✗")
    print("=" * 62)


if __name__ == "__main__":
    run_tests()
