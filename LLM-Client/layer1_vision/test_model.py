# layer1_vision/test_model.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 1 — Test Script
# Run right now without any training data.
#
# Usage:
#   python test_model.py              # full test suite
#   python test_model.py --image path/to/product.jpg  # test on real image
# ─────────────────────────────────────────────────────────────────────────────

import argparse
import torch
from PIL import Image

from model    import VisionAI, get_val_transforms, predict
from dataset  import compute_auto_confidence, parse_order_proxy, parse_rating
from constants import CATEGORIES, MARKET_TYPES, IMAGE_SIZE


# ─────────────────────────────────────────────────────────────────────────────
# TEST 1 — Model Architecture
# ─────────────────────────────────────────────────────────────────────────────

def test_architecture():
    print("── Test 1: Architecture ──────────────────────────────")
    model = VisionAI()

    total     = sum(p.numel() for p in model.parameters())
    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)

    print(f"  Total parameters     : {total:,}")
    print(f"  Trainable parameters : {trainable:,}")

    # Test freeze
    model.freeze_backbone()
    trainable_frozen = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"  After freeze (heads) : {trainable_frozen:,} trainable")

    # Test unfreeze
    model.unfreeze_top_layers(2)
    trainable_unfrozen = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"  After unfreeze top 2 : {trainable_unfrozen:,} trainable")
    print("  ✓ PASS\n")


# ─────────────────────────────────────────────────────────────────────────────
# TEST 2 — Output Shapes & Value Ranges
# ─────────────────────────────────────────────────────────────────────────────

def test_output_shapes():
    print("── Test 2: Output Shapes & Value Ranges ─────────────")
    model = VisionAI()
    model.eval()

    batch_size   = 4
    dummy_images = torch.rand(batch_size, 3, IMAGE_SIZE, IMAGE_SIZE)

    with torch.no_grad():
        cat_logits, wow, market_logits, tiktok = model(dummy_images)

    assert list(cat_logits.shape)    == [batch_size, len(CATEGORIES)],   "Category shape mismatch"
    assert list(wow.shape)           == [batch_size, 1],                 "Wow shape mismatch"
    assert list(market_logits.shape) == [batch_size, len(MARKET_TYPES)], "Market shape mismatch"
    assert list(tiktok.shape)        == [batch_size, 1],                 "TikTok shape mismatch"

    assert wow.min()    >= 0.0 and wow.max()    <= 1.0, "Wow score out of [0,1]"
    assert tiktok.min() >= 0.0 and tiktok.max() <= 1.0, "TikTok score out of [0,1]"

    print(f"  category_logits : {list(cat_logits.shape)} ✓")
    print(f"  wow_score       : {list(wow.shape)} in [0,1] ✓")
    print(f"  market_logits   : {list(market_logits.shape)} ✓")
    print(f"  tiktok_score    : {list(tiktok.shape)} in [0,1] ✓")
    print("  ✓ PASS\n")


# ─────────────────────────────────────────────────────────────────────────────
# TEST 3 — Predict Helper
# ─────────────────────────────────────────────────────────────────────────────

def test_predict():
    print("── Test 3: Predict Helper ────────────────────────────")
    model  = VisionAI()
    image  = torch.rand(1, 3, IMAGE_SIZE, IMAGE_SIZE)
    result = predict(model, image)

    assert "category"      in result, "Missing category"
    assert "wow_score"     in result, "Missing wow_score"
    assert "market_type"   in result, "Missing market_type"
    assert "tiktokability" in result, "Missing tiktokability"
    assert result["category"]    in CATEGORIES,    f"Unknown category: {result['category']}"
    assert result["market_type"] in MARKET_TYPES,  f"Unknown market type: {result['market_type']}"
    assert 0.0 <= result["wow_score"]     <= 1.0,  "wow_score out of range"
    assert 0.0 <= result["tiktokability"] <= 1.0,  "tiktokability out of range"

    print(f"  category      : {result['category']} ✓")
    print(f"  wow_score     : {result['wow_score']} ✓")
    print(f"  market_type   : {result['market_type']} ✓")
    print(f"  tiktokability : {result['tiktokability']} ✓")
    print("  ✓ PASS\n")


# ─────────────────────────────────────────────────────────────────────────────
# TEST 4 — Auto Confidence Logic
# ─────────────────────────────────────────────────────────────────────────────

def test_auto_confidence():
    print("── Test 4: Auto Confidence Logic ────────────────────")

    cases = [
        (10000, 4.7, "high"),    # both strong
        (8000,  3.9, "medium"),  # orders only
        (100,   4.8, "medium"),  # rating only
        (50,    3.5, "low"),     # neither
    ]

    for orders, rating, expected in cases:
        result = compute_auto_confidence(orders, rating)
        status = "✓" if result == expected else "✗"
        print(f"  orders={orders:>6}, rating={rating} → {result:<8} {status}")
        assert result == expected, f"Expected {expected}, got {result}"

    # Test string parsing
    assert parse_order_proxy("10,000+ sold") == 10000
    assert parse_order_proxy("10k+")         == 10000
    assert parse_order_proxy("1.5m")         == 1_500_000
    assert parse_rating("4.7 out of 5")      == 4.7
    assert parse_rating("4.7/5")             == 4.7
    print("  String parsing ✓")
    print("  ✓ PASS\n")


# ─────────────────────────────────────────────────────────────────────────────
# TEST 5 — Real Image (optional)
# ─────────────────────────────────────────────────────────────────────────────

def test_real_image(image_path: str):
    print(f"── Test 5: Real Image ────────────────────────────────")
    print(f"  Image: {image_path}")

    model     = VisionAI()
    transform = get_val_transforms()

    image  = Image.open(image_path).convert("RGB")
    tensor = transform(image).unsqueeze(0)
    result = predict(model, tensor)

    print(f"  category      : {result['category']}")
    print(f"  wow_score     : {result['wow_score']}")
    print(f"  market_type   : {result['market_type']}")
    print(f"  tiktokability : {result['tiktokability']}")
    print(f"  Note: scores are random — model not trained yet")
    print("  ✓ PASS\n")


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", default=None, help="Path to a real product image")
    args = parser.parse_args()

    print("=" * 55)
    print("  Layer 1 Vision AI — Test Suite")
    print("=" * 55 + "\n")

    test_architecture()
    test_output_shapes()
    test_predict()
    test_auto_confidence()

    if args.image:
        test_real_image(args.image)

    print("=" * 55)
    print("  All tests passed ✓")
    print("=" * 55)
