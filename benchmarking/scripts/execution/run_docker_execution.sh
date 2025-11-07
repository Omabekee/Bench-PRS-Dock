#!/usr/bin/env bash
# =============================================================
# Script: run_docker_execution.sh
# Purpose: Measure Docker execution time for any PRS tool container
# Usage:
#   bash examples/verification/run_docker_execution.sh TOOL_NAME "<docker_run_command>" [--cold]
# Example:
#   bash examples/verification/run_docker_execution.sh prscsx "docker run --rm chiomab/prscsx:latest ..."
# =============================================================

set -euo pipefail

TOOL=${1:-}
EXEC_CMD=${2:-}
COLD_FLAG=${3:-}

if [ -z "$TOOL" ] || [ -z "$EXEC_CMD" ]; then
  echo "Usage: bash examples/verification/run_docker_execution.sh TOOL_NAME \"<docker_run_command>\" [--cold]"
  exit 1
fi

# -------------------------------------------------------------
# Ensure results directories exist (per-tool and global)
# -------------------------------------------------------------
BASE_ROOT="/home/bonyido/bench-prs-dock/results/execution_benchmarks"
BASE_DIR="${BASE_ROOT}/${TOOL}/docker"

mkdir -p "$BASE_DIR" || {
  echo "Error: could not create $BASE_DIR"
  exit 1
}

LOG_FILE="${BASE_DIR}/docker_output.log"
GLOBAL_LOG="${BASE_ROOT}/runtime_log.csv"

# -------------------------------------------------------------
# Pre-clean (optional cold mode)
# -------------------------------------------------------------

{
  echo "Docker execution benchmark for '${TOOL}'"
  echo "Command: $EXEC_CMD"
  if [ "${COLD_FLAG:-}" = "--cold" ]; then
    echo "Cold mode enabled: pruning cache and volumes before execution."
    docker system prune -af
    docker builder prune -af
    docker volume prune -f || true
  fi
  echo "Starting timed Docker run..."
} | tee "$LOG_FILE"

# Timed execution

examples/verification/measure_time_execution.sh docker "$EXEC_CMD" 2>&1 | tee -a "$LOG_FILE"

# Finalize
echo "Completed Docker execution benchmark for ${TOOL}." | tee -a "$LOG_FILE"