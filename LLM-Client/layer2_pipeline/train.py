"""
Layer 2 — Training Script
==========================
Run this when the data team delivers the labeled dataset.

Usage:
    python train.py --data ./layer2_dataset_v1/labels/labels.jsonl
                    --texts  ./layer2_dataset_v1/texts/
                    --output ./checkpoints/
                    --epochs 5

Two-stage training:
    Stage 1 (epochs 1-3) : backbone frozen, train heads only
    Stage 2 (epochs 4-5) : unfreeze top 2 transformer layers
"""

import os
import json
import argparse
import numpy as np
from pathlib import Path

import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
from transformers import DistilBertTokenizerFast
from torch.optim import AdamW
from torch.optim.lr_scheduler import LinearLR

from model import (
    ProductExtractor, MAX_LENGTH,
    NER_LABEL2ID, NER_ID2LABEL,
    ANGLE_LABELS, AUDIENCE_LABELS,
)

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


# ─────────────────────────────────────────────────────────────────────────────
# DATASET
# ─────────────────────────────────────────────────────────────────────────────

class ProductTextDataset(Dataset):
    """
    Loads labels.jsonl and tokenizes text on the fly.

    Expected label format per line:
    {
      "text_id": "txt_00142",
      "raw_text": "...",
      "tokens": ["Portable", "LED", ...],
      "ner_labels": ["B-PRODUCT", "I-PRODUCT", ...],
      "marketing_angle": 1,
      "audience_size": "mass"
    }
    """

    def __init__(self, jsonl_path: str, tokenizer, max_length: int = MAX_LENGTH):
        self.tokenizer  = tokenizer
        self.max_length = max_length
        self.samples    = []

        with open(jsonl_path, "r") as f:
            for line in f:
                line = line.strip()
                if line:
                    self.samples.append(json.loads(line))

        print(f"Loaded {len(self.samples)} samples from {jsonl_path}")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        sample  = self.samples[idx]
        tokens  = sample["tokens"]
        ner_tags = [NER_LABEL2ID[t] for t in sample["ner_labels"]]

        # Tokenize with word-to-token alignment
        encoding = self.tokenizer(
            tokens,
            is_split_into_words=True,       # tokens already split
            max_length=self.max_length,
            padding="max_length",
            truncation=True,
            return_tensors="pt",
        )

        # Align NER labels to subword tokens
        # First subword of word → real label, subsequent subwords → -100 (ignored in loss)
        word_ids     = encoding.word_ids(batch_index=0)
        aligned_ner  = []
        prev_word_id = None
        for word_id in word_ids:
            if word_id is None:
                aligned_ner.append(-100)           # [CLS], [SEP], [PAD]
            elif word_id != prev_word_id:
                label = ner_tags[word_id] if word_id < len(ner_tags) else -100
                aligned_ner.append(label)
            else:
                aligned_ner.append(-100)           # subword continuation
            prev_word_id = word_id

        # Classification labels
        angle_id    = sample["marketing_angle"]
        audience_id = AUDIENCE_LABELS.index(sample["audience_size"])

        return {
            "input_ids":      encoding["input_ids"].squeeze(0),
            "attention_mask": encoding["attention_mask"].squeeze(0),
            "ner_labels":     torch.tensor(aligned_ner,  dtype=torch.long),
            "angle_label":    torch.tensor(angle_id,     dtype=torch.long),
            "audience_label": torch.tensor(audience_id,  dtype=torch.long),
        }


# ─────────────────────────────────────────────────────────────────────────────
# LOSS FUNCTION
# ─────────────────────────────────────────────────────────────────────────────

def compute_loss(ner_logits, angle_logits, audience_logits,
                 ner_labels, angle_labels, audience_labels):
    """
    Combined multi-task loss.
    NER loss weighted higher — it's the harder task.
    """
    ce_loss = nn.CrossEntropyLoss(ignore_index=-100)

    ner_loss = ce_loss(
        ner_logits.view(-1, ner_logits.size(-1)),
        ner_labels.view(-1),
    )
    angle_loss    = ce_loss(angle_logits,    angle_labels)
    audience_loss = ce_loss(audience_logits, audience_labels)

    # Weighted combination — NER is harder, weight it more
    total_loss = (ner_loss * 1.0) + (angle_loss * 0.5) + (audience_loss * 0.3)
    return total_loss, ner_loss, angle_loss, audience_loss


# ─────────────────────────────────────────────────────────────────────────────
# EVALUATION
# ─────────────────────────────────────────────────────────────────────────────

def evaluate(model, dataloader):
    model.eval()
    total_ner_correct = total_ner_tokens = 0
    total_angle_correct = total_audience_correct = total_samples = 0

    with torch.no_grad():
        for batch in dataloader:
            input_ids      = batch["input_ids"].to(DEVICE)
            attention_mask = batch["attention_mask"].to(DEVICE)
            ner_labels     = batch["ner_labels"].to(DEVICE)
            angle_labels   = batch["angle_label"].to(DEVICE)
            audience_labels = batch["audience_label"].to(DEVICE)

            ner_logits, angle_logits, audience_logits = model(input_ids, attention_mask)

            # NER accuracy (ignore -100 padding)
            ner_preds = torch.argmax(ner_logits, dim=-1)
            mask = ner_labels != -100
            total_ner_correct += (ner_preds[mask] == ner_labels[mask]).sum().item()
            total_ner_tokens  += mask.sum().item()

            # Classification accuracy
            angle_preds    = torch.argmax(angle_logits, dim=-1)
            audience_preds = torch.argmax(audience_logits, dim=-1)
            total_angle_correct    += (angle_preds    == angle_labels).sum().item()
            total_audience_correct += (audience_preds == audience_labels).sum().item()
            total_samples          += input_ids.size(0)

    return {
        "ner_accuracy":      total_ner_correct    / max(total_ner_tokens, 1),
        "angle_accuracy":    total_angle_correct  / max(total_samples, 1),
        "audience_accuracy": total_audience_correct / max(total_samples, 1),
    }


# ─────────────────────────────────────────────────────────────────────────────
# TRAINING LOOP
# ─────────────────────────────────────────────────────────────────────────────

def train(args):
    print(f"Device: {DEVICE}")
    tokenizer = DistilBertTokenizerFast.from_pretrained("distilbert-base-uncased")

    # Load dataset
    dataset = ProductTextDataset(args.data, tokenizer)

    # 80/10/10 split
    n       = len(dataset)
    n_train = int(n * 0.80)
    n_val   = int(n * 0.10)
    n_test  = n - n_train - n_val

    train_set, val_set, test_set = torch.utils.data.random_split(
        dataset, [n_train, n_val, n_test],
        generator=torch.Generator().manual_seed(42)
    )

    train_loader = DataLoader(train_set, batch_size=args.batch_size, shuffle=True)
    val_loader   = DataLoader(val_set,   batch_size=args.batch_size)

    print(f"Train: {len(train_set)} | Val: {len(val_set)} | Test: {len(test_set)}")

    # Model
    model = ProductExtractor().to(DEVICE)

    # Stage 1 — freeze backbone
    model.freeze_backbone()
    optimizer = AdamW(filter(lambda p: p.requires_grad, model.parameters()), lr=1e-3)

    os.makedirs(args.output, exist_ok=True)
    best_angle_acc = 0.0

    for epoch in range(1, args.epochs + 1):

        # Stage 2 — unfreeze top 2 layers from epoch 4
        if epoch == 4:
            print("\n── Stage 2: Unfreezing top 2 transformer layers ──")
            model.unfreeze_top_layers(n_layers=2)
            optimizer = AdamW(
                filter(lambda p: p.requires_grad, model.parameters()),
                lr=1e-4   # lower LR to protect backbone
            )

        model.train()
        epoch_loss = 0.0

        for step, batch in enumerate(train_loader):
            input_ids       = batch["input_ids"].to(DEVICE)
            attention_mask  = batch["attention_mask"].to(DEVICE)
            ner_labels      = batch["ner_labels"].to(DEVICE)
            angle_labels    = batch["angle_label"].to(DEVICE)
            audience_labels = batch["audience_label"].to(DEVICE)

            optimizer.zero_grad()
            ner_logits, angle_logits, audience_logits = model(input_ids, attention_mask)

            loss, ner_l, angle_l, aud_l = compute_loss(
                ner_logits, angle_logits, audience_logits,
                ner_labels, angle_labels, audience_labels,
            )
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()

            epoch_loss += loss.item()

            if step % 20 == 0:
                print(f"  Epoch {epoch} | Step {step}/{len(train_loader)} "
                      f"| Loss {loss.item():.4f} "
                      f"(NER {ner_l.item():.3f} | Angle {angle_l.item():.3f})")

        # Evaluate
        metrics = evaluate(model, val_loader)
        avg_loss = epoch_loss / len(train_loader)

        print(f"\nEpoch {epoch} Summary:")
        print(f"  Avg Loss        : {avg_loss:.4f}")
        print(f"  NER Accuracy    : {metrics['ner_accuracy']*100:.1f}%  (target >85%)")
        print(f"  Angle Accuracy  : {metrics['angle_accuracy']*100:.1f}%")
        print(f"  Audience Acc    : {metrics['audience_accuracy']*100:.1f}%\n")

        # Save best checkpoint
        if metrics["angle_accuracy"] > best_angle_acc:
            best_angle_acc = metrics["angle_accuracy"]
            ckpt_path = os.path.join(args.output, "best_model.pt")
            torch.save(model.state_dict(), ckpt_path)
            print(f"  ✓ New best checkpoint saved → {ckpt_path}\n")

    print(f"Training complete. Best angle accuracy: {best_angle_acc*100:.1f}%")
    print(f"Next step: python model.py --export --output ./exports")


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data",       required=True, help="Path to labels.jsonl")
    parser.add_argument("--output",     default="./checkpoints")
    parser.add_argument("--epochs",     type=int, default=5)
    parser.add_argument("--batch_size", type=int, default=16)
    args = parser.parse_args()
    train(args)
