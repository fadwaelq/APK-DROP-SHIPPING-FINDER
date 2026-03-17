# layer3_scoring/train_xgboost.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 3 v2 — XGBoost Training Script
# ─────────────────────────────────────────────────────────────────────────────
#
# Run this when you have real product outcome data from the user flywheel.
# Outcome data = products users actually sold, with real viral/sales results.
#
# Expected input format (outcomes.jsonl) — one JSON per line:
# {
#   "layer1": { "wow_score": 0.82, "tiktokability": 0.74, ... },
#   "layer2": { "usp": "10x magnification", "marketing_angle": "transformation", ... },
#   "trend_score": 0.65,
#   "outcome": {
#     "actual_viral_score": 8.2,    ← real score from user feedback
#     "sold_well": true,            ← did the product actually sell?
#     "units_sold": 142             ← optional, if user reports it
#   }
# }
#
# Usage:
#   python train_xgboost.py --data ./outcomes.jsonl --output ./xgboost_model.json
# ─────────────────────────────────────────────────────────────────────────────

import os
import json
import argparse
import numpy as np

from constants import DEFAULT_CATEGORY_SATURATION


# ─────────────────────────────────────────────────────────────────────────────
# FEATURE ENGINEERING
# ─────────────────────────────────────────────────────────────────────────────

CATEGORY_INDEX = {cat: i for i, cat in enumerate(DEFAULT_CATEGORY_SATURATION.keys())}
MARKET_INDEX   = {"mass": 0, "niche": 1, "premium": 2}

def build_feature_vector(sample: dict) -> list:
    """
    Convert a raw outcome sample into a fixed-length feature vector.
    Feature order must match XGBoostScoringEngine._score_impl() in scorer.py.
    """
    l1 = sample["layer1"]
    l2 = sample["layer2"]

    return [
        float(l1.get("wow_score",     0.5)),
        float(l1.get("tiktokability", 0.5)),
        float(sample.get("trend_score", 0.5)),
        1.0 if l2.get("usp")            else 0.0,
        1.0 if l2.get("problem_solved") else 0.0,
        float(len(l2.get("key_features", []))),
        float(MARKET_INDEX.get(l1.get("market_type", "mass"), 0)),
        float(CATEGORY_INDEX.get(l1.get("category", "gadget"), 0)),
    ]

FEATURE_NAMES = [
    "wow_score",
    "tiktokability",
    "trend_score",
    "has_usp",
    "has_problem",
    "feature_count",
    "market_type_encoded",
    "category_encoded",
]


# ─────────────────────────────────────────────────────────────────────────────
# DATA LOADING
# ─────────────────────────────────────────────────────────────────────────────

def load_outcomes(jsonl_path: str):
    X, y = [], []
    skipped = 0

    with open(jsonl_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            sample = json.loads(line)

            # Skip samples without outcome label
            outcome = sample.get("outcome", {})
            if "actual_viral_score" not in outcome:
                skipped += 1
                continue

            X.append(build_feature_vector(sample))
            y.append(float(outcome["actual_viral_score"]))

    print(f"Loaded {len(X)} samples ({skipped} skipped — missing outcome label)")
    return np.array(X), np.array(y)


# ─────────────────────────────────────────────────────────────────────────────
# TRAINING
# ─────────────────────────────────────────────────────────────────────────────

def train(args):
    try:
        import xgboost as xgb
        from sklearn.model_selection import train_test_split
        from sklearn.metrics import mean_absolute_error, r2_score
    except ImportError:
        print("Missing dependencies. Run: pip install xgboost scikit-learn")
        return

    print(f"Loading outcome data from {args.data}...")
    X, y = load_outcomes(args.data)

    if len(X) < 50:
        print(f"Warning: only {len(X)} samples. Recommend at least 200 for reliable training.")

    # Train / val split
    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    print(f"Train: {len(X_train)} | Val: {len(X_val)}")

    # Train XGBoost regressor
    model = xgb.XGBRegressor(
        n_estimators      = 200,
        max_depth         = 4,
        learning_rate     = 0.05,
        subsample         = 0.8,
        colsample_bytree  = 0.8,
        random_state      = 42,
        eval_metric       = "mae",
        early_stopping_rounds = 20,
    )

    model.fit(
        X_train, y_train,
        eval_set=[(X_val, y_val)],
        verbose=50,
    )

    # Evaluate
    val_preds = model.predict(X_val)
    mae = mean_absolute_error(y_val, val_preds)
    r2  = r2_score(y_val, val_preds)

    print(f"\nValidation Results:")
    print(f"  MAE : {mae:.3f}  (avg error in viral score units out of 10)")
    print(f"  R²  : {r2:.3f}  (target > 0.70)")

    # Feature importance
    print(f"\nFeature Importances:")
    importances = model.feature_importances_
    for name, imp in sorted(zip(FEATURE_NAMES, importances), key=lambda x: -x[1]):
        bar = "█" * int(imp * 40)
        print(f"  {name:<25} {bar}  {imp:.3f}")

    # Save model
    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    model.save_model(args.output)
    print(f"\nModel saved → {args.output}")
    print(f"To activate: use XGBoostScoringEngine instead of ScoringEngine in scorer.py")


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data",   required=True,              help="Path to outcomes.jsonl")
    parser.add_argument("--output", default="./xgboost_model.json")
    args = parser.parse_args()
    train(args)
