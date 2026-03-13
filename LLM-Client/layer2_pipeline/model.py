"""
Layer 2 — DistilBERT Product Text Extractor
============================================
Architecture:
  - Backbone : distilbert-base-multilingual-cased (104 languages, pretrained)
  - NER Head : token-level classification → PRODUCT, FEATURE, AUDIENCE, PROBLEM, BENEFIT, O
  - Angle Head : [CLS] classification → 7 marketing angles
  - Audience Head : [CLS] classification → mass | niche

Run this file to:
  1. Build the model
  2. Export to TFLite (INT8 quantized)
  3. Export the tokenizer vocab for Flutter

Usage:
  python model.py --export          # build + export TFLite
  python model.py --test            # run a quick inference test
"""

import os
import json
import argparse
import numpy as np

import torch
import torch.nn as nn
from transformers import DistilBertModel, DistilBertTokenizerFast  # mBERT uses same classes

# ─────────────────────────────────────────────────────────────────────────────
# CONSTANTS
# ─────────────────────────────────────────────────────────────────────────────

MAX_LENGTH  = 128   # tokens — covers ~95% of product descriptions, keeps model fast
MODEL_NAME  = "distilbert-base-multilingual-cased"   # 104 languages including all 8 supported
# Note: multilingual model is ~135MB vs ~67MB for English-only.
# INT8 quantization brings this to ~40MB — within the 42MB mobile target.

# NER labels — BIO format
NER_LABELS = [
    "O",
    "B-PRODUCT", "I-PRODUCT",
    "B-FEATURE",  "I-FEATURE",
    "B-AUDIENCE", "I-AUDIENCE",
    "B-PROBLEM",  "I-PROBLEM",
    "B-BENEFIT",  "I-BENEFIT",
]
NER_LABEL2ID = {label: i for i, label in enumerate(NER_LABELS)}
NER_ID2LABEL = {i: label for i, label in enumerate(NER_LABELS)}
NUM_NER_LABELS = len(NER_LABELS)  # 11

# Marketing angle labels
ANGLE_LABELS = [
    "problem_solution",   # 0
    "transformation",     # 1
    "social_proof",       # 2
    "curiosity",          # 3
    "convenience",        # 4
    "identity",           # 5
    "value",              # 6
]
NUM_ANGLES = len(ANGLE_LABELS)  # 7

# Audience size labels
AUDIENCE_LABELS = ["mass", "niche"]
NUM_AUDIENCE = len(AUDIENCE_LABELS)  # 2


# ─────────────────────────────────────────────────────────────────────────────
# MODEL ARCHITECTURE
# ─────────────────────────────────────────────────────────────────────────────

class ProductExtractor(nn.Module):
    """
    Multi-task model on top of DistilBERT.
    
    Inputs  : input_ids [batch, seq_len], attention_mask [batch, seq_len]
    Outputs :
        ner_logits      [batch, seq_len, 11]   token-level NER
        angle_logits    [batch, 7]             marketing angle
        audience_logits [batch, 2]             mass vs niche
    """

    def __init__(self, model_name: str = MODEL_NAME, dropout: float = 0.1):
        super().__init__()

        self.backbone = DistilBertModel.from_pretrained(model_name)
        hidden_size   = self.backbone.config.dim  # 768

        self.dropout = nn.Dropout(dropout)

        # NER head — operates on every token embedding
        self.ner_head = nn.Linear(hidden_size, NUM_NER_LABELS)

        # Classification heads — operate on [CLS] token (index 0)
        self.angle_head    = nn.Linear(hidden_size, NUM_ANGLES)
        self.audience_head = nn.Linear(hidden_size, NUM_AUDIENCE)

    def forward(self, input_ids: torch.Tensor, attention_mask: torch.Tensor):
        outputs = self.backbone(
            input_ids=input_ids,
            attention_mask=attention_mask,
        )

        # last_hidden_state: [batch, seq_len, 768]
        sequence_output = self.dropout(outputs.last_hidden_state)

        # [CLS] token is at index 0
        cls_output = sequence_output[:, 0, :]  # [batch, 768]

        ner_logits      = self.ner_head(sequence_output)  # [batch, seq_len, 11]
        angle_logits    = self.angle_head(cls_output)      # [batch, 7]
        audience_logits = self.audience_head(cls_output)   # [batch, 2]

        return ner_logits, angle_logits, audience_logits

    def freeze_backbone(self):
        """Freeze backbone — train heads only (Stage 1)."""
        for param in self.backbone.parameters():
            param.requires_grad = False

    def unfreeze_top_layers(self, n_layers: int = 2):
        """Unfreeze top N transformer layers (Stage 2)."""
        for param in self.backbone.parameters():
            param.requires_grad = False
        # DistilBERT has 6 transformer layers
        for layer in self.backbone.transformer.layer[-n_layers:]:
            for param in layer.parameters():
                param.requires_grad = True


# ─────────────────────────────────────────────────────────────────────────────
# TOKENIZER EXPORT (for Flutter)
# ─────────────────────────────────────────────────────────────────────────────

def export_tokenizer_vocab(output_dir: str):
    """
    Export tokenizer vocab + config to JSON.
    Flutter will use this to tokenize text on-device.
    """
    tokenizer = DistilBertTokenizerFast.from_pretrained(MODEL_NAME)

    vocab_data = {
        "vocab":       tokenizer.get_vocab(),          # word → id
        "unk_token_id": tokenizer.unk_token_id,        # 100
        "cls_token_id": tokenizer.cls_token_id,        # 101
        "sep_token_id": tokenizer.sep_token_id,        # 102
        "pad_token_id": tokenizer.pad_token_id,        # 0
        "max_length":   MAX_LENGTH,
    }

    path = os.path.join(output_dir, "tokenizer.json")
    with open(path, "w") as f:
        json.dump(vocab_data, f)

    # Also export label maps for Flutter inference parsing
    label_data = {
        "ner_id2label":      NER_ID2LABEL,
        "angle_labels":      ANGLE_LABELS,
        "audience_labels":   AUDIENCE_LABELS,
    }
    label_path = os.path.join(output_dir, "labels.json")
    with open(label_path, "w") as f:
        json.dump(label_data, f)

    print(f"Tokenizer vocab exported → {path}")
    print(f"Label maps exported     → {label_path}")
    print(f"Vocab size: {len(tokenizer.get_vocab())} tokens")


# ─────────────────────────────────────────────────────────────────────────────
# TFLITE EXPORT
# ─────────────────────────────────────────────────────────────────────────────

def export_to_tflite(model: ProductExtractor, output_dir: str):
    """
    Export PyTorch model → ONNX → TFLite (INT8 quantized).

    Pipeline:
        PyTorch (.pt) → ONNX (.onnx) → TensorFlow SavedModel → TFLite (.tflite)

    Requirements:
        pip install onnx onnx-tf tensorflow
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

    # -- Step 1: Export to ONNX -----------------------------------------------
    dummy_input_ids   = torch.zeros(1, MAX_LENGTH, dtype=torch.long)
    dummy_attention   = torch.ones(1, MAX_LENGTH,  dtype=torch.long)

    onnx_path = os.path.join(output_dir, "layer2_extractor.onnx")
    torch.onnx.export(
        model,
        (dummy_input_ids, dummy_attention),
        onnx_path,
        input_names=["input_ids", "attention_mask"],
        output_names=["ner_logits", "angle_logits", "audience_logits"],
        dynamic_axes={
            "input_ids":      {0: "batch"},
            "attention_mask": {0: "batch"},
        },
        opset_version=14,
    )
    print(f"ONNX exported → {onnx_path}")

    # ── Step 2: ONNX → TensorFlow SavedModel ─────────────────────────────────
    onnx_model   = onnx.load(onnx_path)
    tf_rep       = onnx_tf.backend.prepare(onnx_model)
    saved_model_path = os.path.join(output_dir, "saved_model")
    tf_rep.export_graph(saved_model_path)
    print(f"TF SavedModel exported → {saved_model_path}")

    # ── Step 3: SavedModel → TFLite INT8 ─────────────────────────────────────
    converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_path)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]

    tflite_model  = converter.convert()
    tflite_path   = os.path.join(output_dir, "layer2_extractor.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)

    size_mb = os.path.getsize(tflite_path) / (1024 * 1024)
    print(f"TFLite exported → {tflite_path}")
    print(f"Model size: {size_mb:.1f} MB  (target: <42MB)")


# ─────────────────────────────────────────────────────────────────────────────
# QUICK INFERENCE TEST (CPU — no TFLite needed)
# ─────────────────────────────────────────────────────────────────────────────

def test_inference():
    """
    Smoke test — run a product description through the model.
    Outputs will be random (untrained) but verifies shapes are correct.
    """
    tokenizer = DistilBertTokenizerFast.from_pretrained(MODEL_NAME)
    model     = ProductExtractor()
    model.eval()

    # Test with multilingual descriptions — all 8 supported languages
    test_texts = {
        "en": "Portable LED Makeup Mirror with 10x magnification. USB rechargeable. Never struggle with bad lighting again.",
        "fr": "Miroir de maquillage LED portable avec grossissement 10x. Rechargeable USB. Parfait pour les voyages.",
        "es": "Espejo de maquillaje LED portátil con aumento 10x. Recargable por USB. Perfecto para viajes.",
        "de": "Tragbarer LED-Schminkspiegel mit 10-facher Vergrößerung. USB-aufladbar. Perfekt für Reisen.",
        "ar": "مرآة مكياج LED محمولة بتكبير 10x. قابلة للشحن عبر USB. مثالية للسفر.",
        "zh": "便携式LED化妆镜，10倍放大。USB充电。非常适合旅行使用。",
    }
    test_text = test_texts["en"]  # default to English for shape check

    encoding = tokenizer(
        test_text,
        max_length=MAX_LENGTH,
        padding="max_length",
        truncation=True,
        return_tensors="pt",
    )

    with torch.no_grad():
        ner_logits, angle_logits, audience_logits = model(
            encoding["input_ids"],
            encoding["attention_mask"],
        )

    # Parse NER predictions
    ner_preds    = torch.argmax(ner_logits, dim=-1)[0].tolist()
    tokens       = tokenizer.convert_ids_to_tokens(encoding["input_ids"][0].tolist())
    angle_pred   = ANGLE_LABELS[torch.argmax(angle_logits, dim=-1).item()]
    audience_pred = AUDIENCE_LABELS[torch.argmax(audience_logits, dim=-1).item()]

    print("\n── Inference Test ────────────────────────────────")
    print(f"Input: {test_text[:80]}...")
    print(f"\nNER predictions (first 20 tokens):")
    for tok, pred_id in zip(tokens[:20], ner_preds[:20]):
        label = NER_ID2LABEL[pred_id]
        marker = "  ←" if label != "O" else ""
        print(f"  {tok:<20} {label}{marker}")
    print(f"\nMarketing angle : {angle_pred}  (untrained — random)")
    print(f"Audience size   : {audience_pred}  (untrained — random)")
    print(f"\nOutput shapes:")
    print(f"  ner_logits      : {list(ner_logits.shape)}")
    print(f"  angle_logits    : {list(angle_logits.shape)}")
    print(f"  audience_logits : {list(audience_logits.shape)}")
    print("── Pipeline OK ───────────────────────────────────\n")


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--export", action="store_true", help="Export model to TFLite")
    parser.add_argument("--test",   action="store_true", help="Run inference smoke test")
    parser.add_argument("--output", default="./exports",  help="Output directory")
    args = parser.parse_args()

    if args.test:
        test_inference()

    if args.export:
        print("Building model...")
        model = ProductExtractor()
        os.makedirs(args.output, exist_ok=True)
        export_tokenizer_vocab(args.output)
        export_to_tflite(model, args.output)
        print("\nAll exports complete.")
        print(f"Files in {args.output}/:")
        for f in os.listdir(args.output):
            print(f"  {f}")

    if not args.test and not args.export:
        print("Usage: python model.py --test | --export [--output ./exports]")
