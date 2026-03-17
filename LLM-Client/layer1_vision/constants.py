# layer1_vision/constants.py
# ─────────────────────────────────────────────────────────────────────────────
# All constants for the Vision AI model.
# Change values here — nowhere else.
# ─────────────────────────────────────────────────────────────────────────────

# ── Categories ────────────────────────────────────────────────────────────────
CATEGORIES = [
    "gadget",               # 0
    "beauty",               # 1
    "home_kitchen",         # 2
    "fashion_accessories",  # 3
    "pet_kids",             # 4
    "fitness_outdoor",      # 5
]
NUM_CATEGORIES = len(CATEGORIES)
CAT2ID = {cat: i for i, cat in enumerate(CATEGORIES)}
ID2CAT = {i: cat for i, cat in enumerate(CATEGORIES)}

# ── Market Type ───────────────────────────────────────────────────────────────
MARKET_TYPES = ["mass", "niche", "premium"]
NUM_MARKET_TYPES = len(MARKET_TYPES)
MARKET2ID = {m: i for i, m in enumerate(MARKET_TYPES)}
ID2MARKET = {i: m for i, m in enumerate(MARKET_TYPES)}

# ── Regression Heads ──────────────────────────────────────────────────────────
# wow_score and tiktokability are both continuous 0.0–1.0
WOW_SCORE_MIN       = 0.0
WOW_SCORE_MAX       = 1.0
TIKTOKABILITY_MIN   = 0.0
TIKTOKABILITY_MAX   = 1.0

# ── Image Preprocessing ───────────────────────────────────────────────────────
IMAGE_SIZE          = 224          # MobileNetV3 input size
IMAGE_MEAN          = [0.485, 0.456, 0.406]   # ImageNet mean
IMAGE_STD           = [0.229, 0.224, 0.225]   # ImageNet std

# ── Training ──────────────────────────────────────────────────────────────────
STAGE1_LR           = 1e-3        # Stage 1: heads only
STAGE2_LR           = 1e-4        # Stage 2: top layers unfrozen
STAGE1_EPOCHS       = 20
STAGE2_EPOCHS       = 30
BATCH_SIZE          = 32
NUM_WORKERS         = 4

# ── Loss Weights ──────────────────────────────────────────────────────────────
# Combined loss = cat_loss * w1 + wow_loss * w2 + market_loss * w3 + tiktok_loss * w4
LOSS_WEIGHT_CATEGORY    = 1.0
LOSS_WEIGHT_WOW         = 0.8
LOSS_WEIGHT_MARKET      = 0.6
LOSS_WEIGHT_TIKTOK      = 0.8

# ── Auto Confidence (from data team signals) ──────────────────────────────────
# Computed by ML team from order_proxy + rating
# Used to weight training samples
CONFIDENCE_HIGH_ORDER   = 5_000    # order_proxy threshold for high confidence
CONFIDENCE_HIGH_RATING  = 4.3      # rating threshold for high confidence
SAMPLE_WEIGHT_HIGH      = 1.0      # both signals agree
SAMPLE_WEIGHT_MEDIUM    = 0.6      # one signal
SAMPLE_WEIGHT_LOW       = 0.0      # excluded from training

# ── TFLite Export ─────────────────────────────────────────────────────────────
TFLITE_TARGET_SIZE_MB   = 12       # target: <12MB after INT8 quantization
TFLITE_MAX_LATENCY_MS   = 150      # target: <150ms on mid-range Android
