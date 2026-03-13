# layer1_vision/dataset.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 1 — Dataset Loader
# ─────────────────────────────────────────────────────────────────────────────
#
# Loads images + labels from the data team's delivery format.
# Computes auto_confidence from order_proxy + rating.
# Applies sample weighting during training.
#
# Expected folder structure (from data spec):
#   layer1_dataset_v1/
#     images/
#       gadget/      prod_00001.jpg ...
#       beauty/      ...
#       ...
#     labels/
#       labels.jsonl   ← one JSON object per line
# ─────────────────────────────────────────────────────────────────────────────

import os
import json
from PIL import Image
from torch.utils.data import Dataset, WeightedRandomSampler
import torch

from constants import (
    CAT2ID, MARKET2ID,
    CONFIDENCE_HIGH_ORDER, CONFIDENCE_HIGH_RATING,
    SAMPLE_WEIGHT_HIGH, SAMPLE_WEIGHT_MEDIUM, SAMPLE_WEIGHT_LOW,
)


# ─────────────────────────────────────────────────────────────────────────────
# AUTO CONFIDENCE — computed by ML team from data team signals
# ─────────────────────────────────────────────────────────────────────────────

def compute_auto_confidence(order_proxy: int, rating: float) -> str:
    """
    Derive sample confidence from order_proxy and rating.
    Both signals must be strong for high confidence.

    Returns: "high" | "medium" | "low"
    """
    strong_orders = order_proxy > CONFIDENCE_HIGH_ORDER
    strong_rating = rating      > CONFIDENCE_HIGH_RATING

    if strong_orders and strong_rating:
        return "high"
    elif strong_orders or strong_rating:
        return "medium"
    else:
        return "low"

def confidence_to_weight(confidence: str) -> float:
    """Map confidence label to training sample weight."""
    return {
        "high":   SAMPLE_WEIGHT_HIGH,
        "medium": SAMPLE_WEIGHT_MEDIUM,
        "low":    SAMPLE_WEIGHT_LOW,
    }.get(confidence, 0.0)

def parse_order_proxy(raw: any) -> int:
    """
    Parse order_proxy from various formats the data team might deliver.
    Handles: int, "10000", "10,000", "10,000+ sold", "10k+"
    """
    if isinstance(raw, int):
        return raw
    if isinstance(raw, float):
        return int(raw)

    s = str(raw).lower().replace(",", "").replace("+", "").replace(" sold", "").strip()

    if s.endswith("k"):
        return int(float(s[:-1]) * 1_000)
    if s.endswith("m"):
        return int(float(s[:-1]) * 1_000_000)

    try:
        return int(float(s))
    except ValueError:
        return 0

def parse_rating(raw: any) -> float:
    """
    Parse rating from various formats.
    Handles: float, "4.7", "4.7 out of 5", "4.7/5"
    """
    if isinstance(raw, (int, float)):
        return float(raw)

    s = str(raw).split()[0].replace("/5", "").strip()
    try:
        return float(s)
    except ValueError:
        return 0.0


# ─────────────────────────────────────────────────────────────────────────────
# DATASET
# ─────────────────────────────────────────────────────────────────────────────

class ProductImageDataset(Dataset):
    """
    Loads product images and their labels from the data team's delivery.

    Filters out low-confidence samples automatically.
    Validation/test sets use high-confidence samples only.
    """

    def __init__(
        self,
        dataset_root: str,
        transform=None,
        split: str = "train",           # "train" | "val" | "test"
        val_ratio: float   = 0.10,
        test_ratio: float  = 0.10,
        seed: int          = 42,
    ):
        self.dataset_root = dataset_root
        self.transform    = transform
        self.split        = split
        self.samples      = []
        self.weights      = []

        # Load all labels
        labels_path = os.path.join(dataset_root, "labels", "labels.jsonl")
        all_samples = []

        with open(labels_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                label = json.loads(line)

                # Parse raw signals
                order_proxy = parse_order_proxy(label.get("order_proxy", 0))
                rating      = parse_rating(label.get("rating", 0.0))

                # Compute auto confidence
                confidence  = compute_auto_confidence(order_proxy, rating)
                weight      = confidence_to_weight(confidence)

                # Build image path
                category   = label["category"]
                image_id   = label["image_id"]
                image_path = os.path.join(
                    dataset_root, "images", category, f"{image_id}.jpg"
                )
                # Try PNG if JPG not found
                if not os.path.exists(image_path):
                    image_path = image_path.replace(".jpg", ".png")

                if not os.path.exists(image_path):
                    continue   # skip missing images

                all_samples.append({
                    "image_path":  image_path,
                    "category_id": CAT2ID.get(category, 0),
                    "wow_score":   float(label.get("wow_score", 0.5)),
                    "market_id":   MARKET2ID.get(label.get("market_type", "mass"), 0),
                    "tiktok":      float(label.get("tiktokability", 0.5)),
                    "confidence":  confidence,
                    "weight":      weight,
                })

        # Remove low-confidence samples
        all_samples = [s for s in all_samples if s["weight"] > 0.0]

        # Reproducible split — numpy default_rng is used intentionally here.
        # This is a dataset shuffle for ML train/val/test splitting, not a
        # security-sensitive operation. numpy.default_rng is a non-cryptographic
        # seeded PRNG appropriate for reproducible ML experiments (SonarQube S2245).
        import numpy as np
        rng = np.random.default_rng(seed)
        rng.shuffle(all_samples)

        n       = len(all_samples)
        n_test  = int(n * test_ratio)
        n_val   = int(n * val_ratio)
        n_train = n - n_test - n_val

        if split == "train":
            self.samples = all_samples[:n_train]
        elif split == "val":
            # Val: high confidence only
            self.samples = [s for s in all_samples[n_train:n_train + n_val]
                           if s["confidence"] == "high"]
        elif split == "test":
            # Test: high confidence only
            self.samples = [s for s in all_samples[n_train + n_val:]
                           if s["confidence"] == "high"]

        self.weights = [s["weight"] for s in self.samples]

        print(f"[{split.upper()}] {len(self.samples)} samples loaded "
              f"({sum(1 for s in self.samples if s['confidence']=='high')} high, "
              f"{sum(1 for s in self.samples if s['confidence']=='medium')} medium)")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        sample = self.samples[idx]

        # Load image
        image = Image.open(sample["image_path"]).convert("RGB")
        if self.transform:
            image = self.transform(image)

        return {
            "image":       image,
            "category_id": torch.tensor(sample["category_id"], dtype=torch.long),
            "wow_score":   torch.tensor(sample["wow_score"],   dtype=torch.float32),
            "market_id":   torch.tensor(sample["market_id"],   dtype=torch.long),
            "tiktok":      torch.tensor(sample["tiktok"],      dtype=torch.float32),
            "weight":      torch.tensor(sample["weight"],      dtype=torch.float32),
        }

    def get_sampler(self) -> WeightedRandomSampler:
        """
        Returns a WeightedRandomSampler that upsamples high-confidence
        and medium-confidence samples proportionally during training.
        """
        return WeightedRandomSampler(
            weights     = self.weights,
            num_samples = len(self.weights),
            replacement = True,
        )
