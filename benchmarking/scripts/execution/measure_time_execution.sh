#!/usr/bin/env bash
# =============================================================
# Script: measure_time_execution.sh
# Purpose: Benchmark execution time (manual or docker) for any PRS tool
# Usage:
#   bash examples/verification/measure_time_execution.sh manual "<commands>"
#   bash examples/verification/measure_time_execution.sh docker "<commands>"
# =============================================================

MODE=$1
shift
CMD=$*

LOG_FILE="/home/bonyido/bench-prs-dock/results/execution_benchmarks/runtime_log.csv"
mkdir -p "$(dirname "$LOG_FILE")"

if [ -z "$MODE" ] || [ -z "$CMD" ]; then
  echo "Usage: bash measure_time_execution.sh [manual|docker] \"<commands>\""
  exit 1
fi

START=$(date +%s)
echo "Running execution in '$MODE' mode..."
echo "Command: $CMD"

eval "$CMD"
STATUS=$?

END=$(date +%s)
RUNTIME=$((END - START))

if [ ! -f "$LOG_FILE" ]; then
  echo "MODE,COMMAND,EXIT_STATUS,RUNTIME(seconds),DATE" > "$LOG_FILE"
fi
echo "\"$MODE\",\"$CMD\",$STATUS,$RUNTIME,\"$(date)\"" >> "$LOG_FILE"

if [ $STATUS -eq 0 ]; then
  echo "Execution completed successfully in $RUNTIME seconds."
else
  echo "Execution command exited with status $STATUS (check output above)."
fi

echo "Logged to $LOG_FILE"