#!/usr/bin/env bash
# =============================================================
# Script: run_manual_execution.sh
# Purpose: Benchmark manual execution time for PRS tools
# Usage:
#   bash examples/verification/run_manual_execution.sh TOOL_NAME "<execution_commands>"
# =============================================================

TOOL=$1
EXEC_CMD=$2

if [ -z "$TOOL" ] || [ -z "$EXEC_CMD" ]; then
  echo "Usage: bash examples/verification/run_manual_execution.sh TOOL_NAME \"<execution_commands>\""
  exit 1
fi

# -------------------------------------------------------------
# Ensure results directories exist (per-tool and global)
# -------------------------------------------------------------
BASE_ROOT="/home/bonyido/bench-prs-dock/results/execution_benchmarks"
BASE_DIR="${BASE_ROOT}/${TOOL}/manual"

mkdir -p "$BASE_DIR" || {
  echo "Error: could not create $BASE_DIR"
  exit 1
}

LOG_FILE="${BASE_DIR}/manual_output.log"
GLOBAL_LOG="${BASE_ROOT}/runtime_log.csv"

# -------------------------------------------------------------
# Prepare Python environment
# -------------------------------------------------------------

ENV_PATH=~/bench_prs_env
if [ ! -d "$ENV_PATH" ]; then
  echo "Environment not found. Creating new one at $ENV_PATH..."
  python3 -m venv "$ENV_PATH"
fi

source "$ENV_PATH/bin/activate"
pip install --upgrade pip >/dev/null 2>&1

echo "Active Python: $(which python)" | tee "$LOG_FILE"
python -V | tee -a "$LOG_FILE"

# -------------------------------------------------------------
# Run execution benchmark
# -------------------------------------------------------------

echo "Running execution benchmark for '$TOOL'..." | tee -a "$LOG_FILE"
examples/verification/measure_time_execution.sh manual "$EXEC_CMD" 2>&1 | tee -a "$LOG_FILE"

# -------------------------------------------------------------
# Deactivate and finalize
# -------------------------------------------------------------

deactivate
echo "Completed manual execution benchmark for $TOOL." | tee -a "$LOG_FILE"