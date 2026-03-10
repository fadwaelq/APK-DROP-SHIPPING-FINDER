# layer1_vision/train.py
# ─────────────────────────────────────────────────────────────────────────────
# Layer 1 — Training Script
# ─────────────────────────────────────────────────────────────────────────────
#
# Run when the data team delivers the labeled image dataset.
#
# Usage:
#   python train.py --data ./layer1_dataset_v1 --output ./checkpoints
#
# Two-stage training:
#   Stage 1 (epochs 1–20)  : backbone frozen, heads only, LR=1e-3
#   Stage 2 (epochs 21–50) : top 2 backbone blocks unfrozen, LR=1e-4
# ─────────────────────────────────────────────────────────────────────────────

import os
import argparse
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torch.optim import AdamW

from model   import VisionAI, get_train_transforms, get_val_transforms
from dataset import ProductImageDataset
from constants import (
    STAGE1_LR, STAGE2_LR, STAGE1_EPOCHS, STAGE2_EPOCHS,
    BATCH_SIZE, NUM_WORKERS,
    LOSS_WEIGHT_CATEGORY, LOSS_WEIGHT_WOW,
    LOSS_WEIGHT_MARKET, LOSS_WEIGHT_TIKTOK,
)

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


# ─────────────────────────────────────────────────────────────────────────────
# LOSS FUNCTION
# ─────────────────────────────────────────────────────────────────────────────

def compute_loss(
    cat_logits, wow_pred, market_logits, tiktok_pred,
    cat_labels, wow_labels, market_labels, tiktok_labels,
    sample_weights,
):
    """
    Combined multi-task loss across all 4 heads.
    Sample weights applied to focus learning on high-confidence labels.
    """
    ce_loss  = nn.CrossEntropyLoss(reduction="none")
    mse_loss = nn.MSELoss(reduction="none")

    # Classification losses
    cat_loss    = (ce_loss(cat_logits,    cat_labels)    * sample_weights).mean()
    market_loss = (ce_loss(market_logits, market_labels) * sample_weights).mean()

    # Regression losses
    wow_loss    = (mse_loss(wow_pred.squeeze(1),    wow_labels)    * sample_weights).mean()
    tiktok_loss = (mse_loss(tiktok_pred.squeeze(1), tiktok_labels) * sample_weights).mean()

    total = (
        cat_loss    * LOSS_WEIGHT_CATEGORY +
        wow_loss    * LOSS_WEIGHT_WOW      +
        market_loss * LOSS_WEIGHT_MARKET   +
        tiktok_loss * LOSS_WEIGHT_TIKTOK
    )

    return total, cat_loss, wow_loss, market_loss, tiktok_loss


# ─────────────────────────────────────────────────────────────────────────────
# EVALUATION
# ─────────────────────────────────────────────────────────────────────────────

def evaluate(model, dataloader):
    model.eval()
    cat_correct = market_correct = total = 0
    wow_mae = tiktok_mae = 0.0

    with torch.no_grad():
        for batch in dataloader:
            images         = batch["image"].to(DEVICE)
            cat_labels     = batch["category_id"].to(DEVICE)
            wow_labels     = batch["wow_score"].to(DEVICE)
            market_labels  = batch["market_id"].to(DEVICE)
            tiktok_labels  = batch["tiktok"].to(DEVICE)

            cat_logits, wow_pred, market_logits, tiktok_pred = model(images)

            cat_correct    += (torch.argmax(cat_logits,    dim=-1) == cat_labels).sum().item()
            market_correct += (torch.argmax(market_logits, dim=-1) == market_labels).sum().item()
            wow_mae        += torch.abs(wow_pred.squeeze(1)    - wow_labels).sum().item()
            tiktok_mae     += torch.abs(tiktok_pred.squeeze(1) - tiktok_labels).sum().item()
            total          += images.size(0)

    return {
        "category_accuracy": cat_correct    / max(total, 1),
        "market_accuracy":   market_correct / max(total, 1),
        "wow_mae":           wow_mae        / max(total, 1),
        "tiktok_mae":        tiktok_mae     / max(total, 1),
    }


# ─────────────────────────────────────────────────────────────────────────────
# TRAINING LOOP
# ─────────────────────────────────────────────────────────────────────────────

def train(args):
    print(f"Device: {DEVICE}")
    total_epochs = STAGE1_EPOCHS + STAGE2_EPOCHS

    # ── Datasets ──────────────────────────────────────────────────────────────
    train_set = ProductImageDataset(args.data, get_train_transforms(), split="train")
    val_set   = ProductImageDataset(args.data, get_val_transforms(),   split="val")

    train_loader = DataLoader(
        train_set,
        batch_size  = BATCH_SIZE,
        sampler     = train_set.get_sampler(),   # weighted sampling
        num_workers = NUM_WORKERS,
        pin_memory  = True,
    )
    val_loader = DataLoader(
        val_set,
        batch_size  = BATCH_SIZE,
        shuffle     = False,
        num_workers = NUM_WORKERS,
    )

    # ── Model ─────────────────────────────────────────────────────────────────
    model = VisionAI().to(DEVICE)
    model.freeze_backbone()   # Stage 1: heads only
    optimizer = AdamW(
        filter(lambda p: p.requires_grad, model.parameters()),
        lr=STAGE1_LR
    )

    os.makedirs(args.output, exist_ok=True)
    best_cat_acc = 0.0

    print(f"\nStarting training — {total_epochs} epochs total")
    print(f"Stage 1: epochs 1–{STAGE1_EPOCHS} (backbone frozen, LR={STAGE1_LR})")
    print(f"Stage 2: epochs {STAGE1_EPOCHS+1}–{total_epochs} (top 2 blocks, LR={STAGE2_LR})\n")

    for epoch in range(1, total_epochs + 1):

        # ── Stage 2 transition ────────────────────────────────────────────────
        if epoch == STAGE1_EPOCHS + 1:
            print(f"\n── Entering Stage 2 ──────────────────────────────────")
            model.unfreeze_top_layers(n_layers=2)
            optimizer = AdamW(
                filter(lambda p: p.requires_grad, model.parameters()),
                lr=STAGE2_LR
            )

        # ── Train one epoch ───────────────────────────────────────────────────
        model.train()
        epoch_loss = 0.0

        for step, batch in enumerate(train_loader):
            images          = batch["image"].to(DEVICE)
            cat_labels      = batch["category_id"].to(DEVICE)
            wow_labels      = batch["wow_score"].to(DEVICE)
            market_labels   = batch["market_id"].to(DEVICE)
            tiktok_labels   = batch["tiktok"].to(DEVICE)
            sample_weights  = batch["weight"].to(DEVICE)

            optimizer.zero_grad()
            cat_logits, wow_pred, market_logits, tiktok_pred = model(images)

            loss, cat_l, wow_l, market_l, tiktok_l = compute_loss(
                cat_logits, wow_pred, market_logits, tiktok_pred,
                cat_labels, wow_labels, market_labels, tiktok_labels,
                sample_weights,
            )

            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()

            epoch_loss += loss.item()

            if step % 50 == 0:
                stage = 1 if epoch <= STAGE1_EPOCHS else 2
                print(f"  [S{stage}] Epoch {epoch}/{total_epochs} "
                      f"| Step {step}/{len(train_loader)} "
                      f"| Loss {loss.item():.4f} "
                      f"(cat {cat_l.item():.3f} | wow {wow_l.item():.3f} "
                      f"| tiktok {tiktok_l.item():.3f})")

        # ── Evaluate ─────────────────────────────────────────────────────────
        metrics   = evaluate(model, val_loader)
        avg_loss  = epoch_loss / len(train_loader)

        print(f"\nEpoch {epoch}/{total_epochs} Summary:")
        print(f"  Avg Loss          : {avg_loss:.4f}")
        print(f"  Category Accuracy : {metrics['category_accuracy']*100:.1f}%  (target >85%)")
        print(f"  Market Accuracy   : {metrics['market_accuracy']*100:.1f}%")
        print(f"  Wow MAE           : {metrics['wow_mae']:.3f}  (target <0.10)")
        print(f"  TikTok MAE        : {metrics['tiktok_mae']:.3f}  (target <0.10)\n")

        # ── Save best checkpoint ──────────────────────────────────────────────
        if metrics["category_accuracy"] > best_cat_acc:
            best_cat_acc = metrics["category_accuracy"]
            ckpt_path    = os.path.join(args.output, "best_model.pt")
            torch.save(model.state_dict(), ckpt_path)
            print(f"  ✓ New best checkpoint saved → {ckpt_path}\n")

    print(f"Training complete.")
    print(f"Best category accuracy : {best_cat_acc*100:.1f}%")
    print(f"Next step: python model.py --export --output ./exports")


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data",   required=True, help="Path to layer1_dataset_v1/")
    parser.add_argument("--output", default="./checkpoints")
    args = parser.parse_args()
    train(args)
