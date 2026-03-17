# Layer 2 — DistilBERT Pipeline

Product text extraction model for Dropshipping Finder AI.
Runs fully offline on Android via Flutter + TFLite.

---

## Structure

```
layer2_pipeline/
  python/
    model.py            ← Model architecture + TFLite export
    train.py            ← Training script (run when data arrives)
    post_processor.py   ← Rule-based USP + promise derivation
    requirements.txt    ← Python dependencies
  flutter/
    lib/
      tokenizer.dart        ← WordPiece tokenizer (on-device)
      layer2_inference.dart ← TFLite inference engine
    assets/                 ← Drop exported files here
      layer2_extractor.tflite
      tokenizer.json
      labels.json
```

---

## Step 1 — Setup Python Environment

```bash
cd python/
pip install -r requirements.txt
```

---

## Step 2 — Test the Pipeline (No Data Needed)

Run a smoke test to verify model architecture and inference shapes:

```bash
python model.py --test
```

Expected output:
```
── Inference Test ────────────────────────────────
Input: Portable LED Makeup Mirror with 10x magnification...

NER predictions (first 20 tokens):
  [CLS]                O
  portable             B-PRODUCT   ←
  led                  I-PRODUCT   ←
  ...

Marketing angle : problem_solution  (untrained — random)
Audience size   : mass              (untrained — random)

Output shapes:
  ner_logits      : [1, 128, 11]
  angle_logits    : [1, 7]
  audience_logits : [1, 2]
── Pipeline OK ───────────────────────────────────
```

---

## Step 3 — Export to TFLite (Pretrained Weights)

Export the untrained model to TFLite for Flutter integration.
This lets you build and test the Flutter side before training.

```bash
python model.py --export --output ./exports
```

Output files:
```
exports/
  layer2_extractor.tflite   ← model (~40MB)
  tokenizer.json            ← vocab for Flutter tokenizer
  labels.json               ← label maps for output parsing
```

Copy these 3 files into `flutter/assets/`.

---

## Step 4 — Flutter Integration

Add to `pubspec.yaml`:
```yaml
dependencies:
  tflite_flutter: ^0.10.4

flutter:
  assets:
    - assets/layer2_extractor.tflite
    - assets/tokenizer.json
    - assets/labels.json
```

Use in your Flutter code:
```dart
import 'layer2_inference.dart';

// Initialize once at app start
final engine = await Layer2Engine.init();

// Analyze a product description
final result = await engine.analyze(
  text:     "Portable LED Makeup Mirror with 10x magnification...",
  category: "beauty",
);

print(result.usp);            // "10x magnification"
print(result.marketingAngle); // "transformation"  (random until trained)
print(result.mainPromise);    // "Transform with 10x magnification"
print(result.keyFeatures);    // ["10x magnification", "360° rotation", "USB rechargeable"]
```

---

## Step 5 — Train When Data Arrives

When the data team delivers `labels.jsonl`:

```bash
python train.py \
  --data  ./layer2_dataset_v1/labels/labels.jsonl \
  --output ./checkpoints/ \
  --epochs 5 \
  --batch_size 16
```

Training runs in 2 stages automatically:
- Epochs 1–3: backbone frozen, heads only
- Epochs 4–5: top 2 transformer layers unfrozen

---

## Step 6 — Export Trained Model

After training, re-export TFLite with the best checkpoint:

```bash
python model.py --export --output ./exports_trained
```

Replace the `.tflite` file in Flutter assets. Done.

---

## Performance Targets

| Metric           | Target        |
|------------------|---------------|
| Model size       | < 42MB        |
| Inference time   | < 100ms       |
| NER accuracy     | > 85%         |
| Angle accuracy   | > 80%         |
| Min Android ver. | 7.0+          |
| RAM usage        | < 60MB        |

---

## Output JSON Structure

```json
{
  "product_name":    "Portable LED Makeup Mirror",
  "key_features":    ["10x magnification", "360° rotation", "USB rechargeable"],
  "target_audience": ["women", "travel"],
  "problem_solved":  "bad lighting",
  "main_benefit":    "",
  "usp":             "10x magnification",
  "main_promise":    "Transform with 10x magnification",
  "marketing_angle": "transformation",
  "audience_size":   "mass"
}
```

This JSON feeds directly into Layer 3 (Scoring Engine) and Layer 4 (Marketing Generator).
