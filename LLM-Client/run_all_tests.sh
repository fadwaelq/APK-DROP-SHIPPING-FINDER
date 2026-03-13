#!/bin/bash
# run_all_tests.sh
# ─────────────────────────────────────────────────────────────────────────────
# Runs all ML pipeline tests in order.
# Use this before every commit to verify nothing is broken.
#
# Usage:
#   bash run_all_tests.sh           # all tests
#   bash run_all_tests.sh --quick   # skip batch test (faster)
# ─────────────────────────────────────────────────────────────────────────────

set -e   # stop on first failure

QUICK=false
if [[ "$1" == "--quick" ]]; then
  QUICK=true
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

run_test() {
  local name="$1"
  local cmd="$2"
  echo ""
  echo "── $name ─────────────────────────────────────────────"
  if eval "$cmd"; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
  else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
  fi
}

echo "════════════════════════════════════════════════════════"
echo "  LLM-Client — Full Test Suite"
echo "════════════════════════════════════════════════════════"

# Layer 0 — Preprocessing
run_test "Layer 0 — Preprocessing" \
  "cd '$ROOT/preprocessing' && python test_preprocessor.py"

# Layer 1 — Vision AI (smoke test — no dataset needed)
run_test "Layer 1 — Vision AI (smoke test)" \
  "cd '$ROOT/layer1_vision' && python model.py --test"

# Layer 2 — Text Extraction (model test)
run_test "Layer 2 — Text Extraction (post_processor)" \
  "cd '$ROOT/layer2_pipeline' && python post_processor.py"

# Layer 2 — Review Analyzer
run_test "Layer 2 — Review Analyzer" \
  "cd '$ROOT/layer2_pipeline' && python review_analyzer.py"

# Layer 3 — Scoring Engine
run_test "Layer 3 — Scoring Engine" \
  "cd '$ROOT/layer3_scoring' && python test_scorer.py"

# Layer 3 — Seasonality
run_test "Layer 3 — Seasonality" \
  "cd '$ROOT/layer3_scoring' && python seasonality.py"

# Layer 4 — Generator
run_test "Layer 4 — Content Generator" \
  "cd '$ROOT/layer4_generator' && python test_generator.py"

# Integration — Single product
run_test "Integration — Single Product (4 tests, 15 checks each)" \
  "cd '$ROOT' && python integration_test.py"

# Integration — Batch pipeline
if [[ "$QUICK" = false ]]; then
  run_test "Integration — Batch Pipeline (13 checks)" \
    "cd '$ROOT' && python integration_test.py --batch"
else
  echo ""
  echo "── Batch Pipeline test SKIPPED (--quick mode) ────────"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
if [[ $FAIL -eq 0 ]]; then
  echo "  ✅ All tests passed — safe to commit"
else
  echo "  ❌ $FAIL test(s) failed — fix before committing"
fi
echo "════════════════════════════════════════════════════════"

exit $FAIL
