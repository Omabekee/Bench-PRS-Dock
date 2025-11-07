#!/usr/bin/env bash
# =============================================================
# Script: measure_time_setup.sh
# Purpose: Benchmark setup time (manual install or docker pull)
#          for any PRS tool in a reproducible, publication-ready way.
#
# Usage:
#   bash examples/verification/measure_time_setup.sh manual "<commands>"
#   bash examples/verification/measure_time_setup.sh docker "<commands>"
#
# Example (PRS-CSx manual):
#   bash examples/verification/measure_time_setup.sh manual "
#       git clone https://github.com/getian107/PRScsx.git &&
#       cd PRScsx &&
#       pip install scipy h5py"
#
# Example (PRS-CSx docker):
#   bash examples/verification/measure_time_setup.sh docker "
#       docker pull chiomab/prscsx:latest"
# =============================================================

MODE=$1          # manual or docker
shift
CMD=$*           # the setup command(s) to execute

LOG_FILE="/home/bonyido/bench-prs-dock/results/setup_benchmarks/setup_log.csv"
mkdir -p "$(dirname "$LOG_FILE")"

if [ -z "$MODE" ] || [ -z "$CMD" ]; then
  echo "Usage: bash measure_time_setup.sh [manual|docker] \"<commands>\""
  exit 1
fi

# Start timing
START=$(date +%s)

echo "Running setup in '$MODE' mode..."
echo "Command: $CMD"

# Execute the provided command(s)
eval "$CMD"
STATUS=$?

END=$(date +%s)
RUNTIME=$((END - START))

# Logging
if [ ! -f "$LOG_FILE" ]; then
  echo "MODE,COMMAND,EXIT_STATUS,SETUP_TIME(seconds),DATE" > "$LOG_FILE"
fi
echo "\"$MODE\",\"$CMD\",$STATUS,$RUNTIME,\"$(date)\"" >> "$LOG_FILE"

if [ $STATUS -eq 0 ]; then
  echo "Setup completed successfully in $RUNTIME seconds."
else
  echo "Setup command exited with status $STATUS (check output above)."
fi

echo "Logged to $LOG_FILE"