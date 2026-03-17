# layer1_vision/model.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 1 — Vision AI Model
# ─────────────────────────────────────────────────────────────────────────────
#
# Architecture:
#   Backbone : MobileNetV3-Small pretrained on ImageNet
#   Head 1   : Category classification (6 classes)
#   Head 2   : Wow Factor score (regression, 0.0–1.0)
#   Head 3   : Market Type classification (3 classes)
#   Head 4   : TikTokability score (regression, 0.0–1.0)
#
# Single forward pass → all 4 outputs simultaneously
#
# Usage:
#   python model.py --test       # smoke test with random image
#   python model.py --export     # export to TFLite INT8
# ─────────────────────────────────────────────────────────────────────────────

import os
import json
import argparse
import numpy as np
import torch
import torch.nn as nn
from torchvision import transforms
from torchvision.models import mobilenet_v3_small, MobileNet_V3_Small_Weights

from constants import (
    NUM_CATEGORIES, NUM_MARKET_TYPES,
    IMAGE_SIZE, IMAGE_MEAN, IMAGE_STD,
    ID2CAT, ID2MARKET,
    TFLITE_TARGET_SIZE_MB,
)


# ─────────────────────────────────────────────────────────────────────────────
# MODEL ARCHITECTURE
# ─────────────────────────────────────────────────────────────────────────────

class VisionAI(nn.Module):
    """
    MobileNetV3-Small with 4 task-specific heads.

    Inputs  : image tensor [batch, 3, 224, 224]
    Outputs :
        category_logits  [batch, 6]    → category classification
        wow_score        [batch, 1]    → wow factor regression
        market_logits    [batch, 3]    → market type classification
        tiktok_score     [batch, 1]    → tiktokability regression
    """

    def __init__(self, dropout: float = 0.2):
        super().__init__()

        # ── Backbone ──────────────────────────────────────────────────────────
        backbone = mobilenet_v3_small(weights=MobileNet_V3_Small_Weights.IMAGENET1K_V1)

        # Remove the original classifier — we replace it with our 4 heads
        # MobileNetV3-Small features output: 576-dim vector
        self.features   = backbone.features
        self.avgpool    = backbone.avgpool
        hidden_size     = 576

        self.dropout = nn.Dropout(p=dropout)

        # ── Classification Heads ──────────────────────────────────────────────
        self.category_head = nn.Sequential(
            nn.Linear(hidden_size, 128),
            nn.Hardswish(),
            nn.Dropout(p=dropout),
            nn.Linear(128, NUM_CATEGORIES),
        )

        self.market_head = nn.Sequential(
            nn.Linear(hidden_size, 64),
            nn.Hardswish(),
            nn.Dropout(p=dropout),
            nn.Linear(64, NUM_MARKET_TYPES),
        )

        # ── Regression Heads ──────────────────────────────────────────────────
        # Sigmoid ensures output is clamped to 0.0–1.0
        self.wow_head = nn.Sequential(
            nn.Linear(hidden_size, 64),
            nn.Hardswish(),
            nn.Dropout(p=dropout),
            nn.Linear(64, 1),
            nn.Sigmoid(),
        )

        self.tiktok_head = nn.Sequential(
            nn.Linear(hidden_size, 64),
            nn.Hardswish(),
            nn.Dropout(p=dropout),
            nn.Linear(64, 1),
            nn.Sigmoid(),
        )

    def forward(self, x: torch.Tensor):
        # Extract features
        x = self.features(x)
        x = self.avgpool(x)
        x = torch.flatten(x, 1)   # [batch, 576]
        x = self.dropout(x)

        # All 4 heads run on the same feature vector
        category_logits = self.category_head(x)   # [batch, 6]
        wow_score       = self.wow_head(x)         # [batch, 1]
        market_logits   = self.market_head(x)      # [batch, 3]
        tiktok_score    = self.tiktok_head(x)      # [batch, 1]

        return category_logits, wow_score, market_logits, tiktok_score

    def freeze_backbone(self):
        """Stage 1 — freeze backbone, train heads only."""
        for param in self.features.parameters():
            param.requires_grad = False
        print("Backbone frozen — training heads only")

    def unfreeze_top_layers(self, n_layers: int = 2):
        """Stage 2 — unfreeze last N blocks of the backbone."""
        for param in self.features.parameters():
            param.requires_grad = False

        # MobileNetV3-Small has 13 feature blocks (0–12)
        total_blocks = len(self.features)
        for i in range(total_blocks - n_layers, total_blocks):
            for param in self.features[i].parameters():
                param.requires_grad = True

        trainable = sum(p.numel() for p in self.parameters() if p.requires_grad)
        print(f"Unfroze top {n_layers} backbone blocks — {trainable:,} trainable params")


# ─────────────────────────────────────────────────────────────────────────────
# IMAGE PREPROCESSING
# ─────────────────────────────────────────────────────────────────────────────

def get_train_transforms():
    """Augmentation transforms for training."""
    return transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.RandomCrop(IMAGE_SIZE),
        transforms.RandomHorizontalFlip(),
        transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.2),
        transforms.RandomRotation(15),
        transforms.ToTensor(),
        transforms.Normalize(mean=IMAGE_MEAN, std=IMAGE_STD),
    ])

def get_val_transforms():
    """Deterministic transforms for validation and inference."""
    return transforms.Compose([
        transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(mean=IMAGE_MEAN, std=IMAGE_STD),
    ])


# ─────────────────────────────────────────────────────────────────────────────
# INFERENCE HELPER
# ─────────────────────────────────────────────────────────────────────────────

def predict(model: VisionAI, image_tensor: torch.Tensor, device: str = "cpu") -> dict:
    """
    Run inference on a single preprocessed image tensor.

    Args:
        model:        trained VisionAI model
        image_tensor: [1, 3, 224, 224] normalized tensor
        device:       "cpu" or "cuda"

    Returns:
        dict with category, wow_score, market_type, tiktokability
    """
    model.eval()
    image_tensor = image_tensor.to(device)

    with torch.no_grad():
        cat_logits, wow, market_logits, tiktok = model(image_tensor)

    category_id = torch.argmax(cat_logits, dim=-1).item()
    market_id   = torch.argmax(market_logits, dim=-1).item()

    return {
        "category":      ID2CAT[category_id],
        "wow_score":     round(wow.item(), 3),
        "market_type":   ID2MARKET[market_id],
        "tiktokability": round(tiktok.item(), 3),
    }


# ─────────────────────────────────────────────────────────────────────────────
# TFLITE EXPORT — INT8 Quantization
# ─────────────────────────────────────────────────────────────────────────────

def export_to_tflite(model: VisionAI, output_dir: str):
    """
    Export PyTorch model -> ONNX -> TensorFlow -> TFLite INT8.

    Requirements:
        pip install onnx onnx-tf tensorflow

    Output:
        layer1_vision.tflite  -- INT8 quantized, target <12MB
    """
    try:
        import onnx          # noqa: PLC0415
        import onnx_tf       # noqa: PLC0415
        import tensorflow as tf  # noqa: PLC0415
    except ImportError as exc:
        raise ImportError(
            "Export dependencies missing. Run: pip install onnx onnx-tf tensorflow"
        ) from exc

    model.eval()
    os.makedirs(output_dir, exist_ok=True)

    # ── Step 1: PyTorch → ONNX ───────────────────────────────────────────────
    dummy_input = torch.zeros(1, 3, IMAGE_SIZE, IMAGE_SIZE)
    onnx_path   = os.path.join(output_dir, "layer1_vision.onnx")

    torch.onnx.export(
        model,
        dummy_input,
        onnx_path,
        input_names  = ["image"],
        output_names = ["category_logits", "wow_score", "market_logits", "tiktok_score"],
        dynamic_axes = {"image": {0: "batch"}},
        opset_version = 14,
    )
    print(f"ONNX exported → {onnx_path}")

    # ── Step 2: ONNX → TF SavedModel ─────────────────────────────────────────
    onnx_model       = onnx.load(onnx_path)
    tf_rep           = onnx_tf.backend.prepare(onnx_model)
    saved_model_path = os.path.join(output_dir, "saved_model")
    tf_rep.export_graph(saved_model_path)
    print(f"TF SavedModel exported → {saved_model_path}")

    # ── Step 3: SavedModel → TFLite INT8 ─────────────────────────────────────
    def representative_dataset():
        """Feed random images for INT8 calibration."""
        for _ in range(100):
            data = np.random.rand(1, IMAGE_SIZE, IMAGE_SIZE, 3).astype(np.float32)
            yield [data]

    converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_path)
    converter.optimizations                    = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset           = representative_dataset
    converter.target_spec.supported_ops        = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type             = tf.uint8
    converter.inference_output_type            = tf.uint8

    tflite_model = converter.convert()
    tflite_path  = os.path.join(output_dir, "layer1_vision.tflite")

    with open(tflite_path, "wb") as f:
        f.write(tflite_model)

    size_mb = os.path.getsize(tflite_path) / (1024 * 1024)
    print(f"TFLite INT8 exported → {tflite_path}")
    print(f"Model size : {size_mb:.1f} MB  (target: <{TFLITE_TARGET_SIZE_MB}MB)")

    if size_mb > TFLITE_TARGET_SIZE_MB:
        print(f"WARNING: Model exceeds {TFLITE_TARGET_SIZE_MB}MB target")
    else:
        print(f"✓ Size target met")

    # ── Export label maps for mobile team ────────────────────────────────────
    labels = {
        "categories":   {str(k): v for k, v in ID2CAT.items()},
        "market_types": {str(k): v for k, v in ID2MARKET.items()},
        "image_size":   IMAGE_SIZE,
        "image_mean":   IMAGE_MEAN,
        "image_std":    IMAGE_STD,
    }
    labels_path = os.path.join(output_dir, "layer1_labels.json")
    with open(labels_path, "w") as f:
        json.dump(labels, f, indent=2)
    print(f"Label maps exported → {labels_path}")


# ─────────────────────────────────────────────────────────────────────────────
# SMOKE TEST
# ─────────────────────────────────────────────────────────────────────────────

def test_inference():
    """
    Smoke test with a random image tensor.
    Verifies output shapes and value ranges.
    No training data needed.
    """
    model = VisionAI()
    model.eval()

    # Random image — simulates a real product photo
    dummy_image = torch.rand(1, 3, IMAGE_SIZE, IMAGE_SIZE)

    with torch.no_grad():
        cat_logits, wow, market_logits, tiktok = model(dummy_image)

    result = predict(model, dummy_image)

    print("\n── Inference Smoke Test ──────────────────────────────")
    print(f"Input shape    : {list(dummy_image.shape)}")
    print(f"\nOutput shapes:")
    print(f"  category_logits : {list(cat_logits.shape)}  → {NUM_CATEGORIES} classes")
    print(f"  wow_score       : {list(wow.shape)}        → range [0.0, 1.0]")
    print(f"  market_logits   : {list(market_logits.shape)}  → {NUM_MARKET_TYPES} classes")
    print(f"  tiktok_score    : {list(tiktok.shape)}        → range [0.0, 1.0]")
    print(f"\nDecoded prediction (untrained — random):")
    print(f"  category      : {result['category']}")
    print(f"  wow_score     : {result['wow_score']}")
    print(f"  market_type   : {result['market_type']}")
    print(f"  tiktokability : {result['tiktokability']}")
    print(f"\nValue range checks:")
    print(f"  wow_score     in [0,1] : {0.0 <= result['wow_score'] <= 1.0}")
    print(f"  tiktokability in [0,1] : {0.0 <= result['tiktokability'] <= 1.0}")

    total_params     = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"\nModel parameters:")
    print(f"  Total     : {total_params:,}")
    print(f"  Trainable : {trainable_params:,}")
    print("── Pipeline OK ───────────────────────────────────────\n")


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--test",   action="store_true", help="Run smoke test")
    parser.add_argument("--export", action="store_true", help="Export to TFLite INT8")
    parser.add_argument("--output", default="./exports",  help="Export output directory")
    args = parser.parse_args()

    if args.test:
        test_inference()

    if args.export:
        print("Building model...")
        model = VisionAI()
        export_to_tflite(model, args.output)

    if not args.test and not args.export:
        print("Usage: python model.py --test | --export [--output ./exports]")
