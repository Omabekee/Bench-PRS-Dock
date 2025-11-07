#!/usr/bin/env bash
# =============================================================
# Script: run_manual_setup.sh
# Purpose: Clear dependencies (not venv) before running setup benchmark
# =============================================================

TOOL=$1
SETUP_CMD=$2

if [ -z "$TOOL" ] || [ -z "$SETUP_CMD" ]; then
  echo "Usage: bash examples/verification/run_manual_setup.sh TOOL_NAME \"<setup_commands>\""
  exit 1
fi

BASE_DIR="/home/bonyido/bench-prs-dock/results/setup_benchmarks/${TOOL}"
mkdir -p "$BASE_DIR"

LOG_FILE="${BASE_DIR}/manual_output.log"

ENV_PATH=~/bench_prs_env
if [ -d "$ENV_PATH" ]; then
  echo "Removing existing environment at $ENV_PATH..."
  rm -rf "$ENV_PATH"
fi

echo "Creating new environment at $ENV_PATH..."
python3 -m venv "$ENV_PATH"
source "$ENV_PATH/bin/activate"
pip install --upgrade pip >/dev/null 2>&1

echo "Active Python: $(which python)" | tee "$LOG_FILE"
python -V | tee -a "$LOG_FILE"

echo "Clearing pip cache..." | tee -a "$LOG_FILE"
rm -rf ~/.cache/pip || true

# =============================================================
# Clean R library if tool involves R (e.g. XPASS, etc.)
# =============================================================
if echo "$SETUP_CMD" | grep -qi "Rscript"; then
  echo "Detected R-based tool — cleaning existing R user library..." | tee -a "$LOG_FILE"
  if [ -d ~/R/x86_64-pc-linux-gnu-library ]; then
    rm -rf ~/R/x86_64-pc-linux-gnu-library/* || true
    echo "Removed existing R packages in ~/R/x86_64-pc-linux-gnu-library/" | tee -a "$LOG_FILE"
  else
    echo "No R library directory found. Skipping cleanup." | tee -a "$LOG_FILE"
  fi
fi

echo "Running setup benchmark for '$TOOL'..." | tee -a "$LOG_FILE"
examples/verification/measure_time_setup.sh manual "$SETUP_CMD" 2>&1 | tee -a "$LOG_FILE"

deactivate
echo "Completed run for $TOOL (fresh environment created, dependencies fully reinstalled)." | tee -a "$LOG_FILE"
