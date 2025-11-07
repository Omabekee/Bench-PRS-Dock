#!/usr/bin/env bash
# =============================================================
# Script: run_setup_docker.sh
# Purpose: Measure setup time for Docker image pulls with optional reset
# =============================================================

set -euo pipefail

TOOL=${1:-}
SETUP_CMD=${2:-}
COLD_FLAG=${3:-}

if [ -z "$TOOL" ] || [ -z "$SETUP_CMD" ]; then
  echo "Usage: bash examples/verification/run_setup_docker.sh TOOL_NAME \"<docker_pull_command>\" [--cold]"
  exit 1
fi

BASE_DIR="/home/bonyido/bench-prs-dock/results/setup_benchmarks/${TOOL}"
mkdir -p "$BASE_DIR"
LOG_FILE="${BASE_DIR}/docker_output.log"

IMAGE_REF="$(echo "$SETUP_CMD" | sed -n 's/.*docker[[:space:]]\+pull[[:space:]]\+\([^[:space:]]\+\).*/\1/p')"

{
  echo "Docker setup benchmark for '${TOOL}'"
  echo "Command: $SETUP_CMD"
  if [ -n "$IMAGE_REF" ]; then
    echo "Detected image: $IMAGE_REF"
  fi

  if [ "${COLD_FLAG:-}" = "--cold" ]; then
    echo "Cold mode enabled: pruning all images and caches."
    docker system prune -af
    docker builder prune -af
    docker volume prune -f || true
  else
    if [ -n "$IMAGE_REF" ] && docker image inspect "$IMAGE_REF" >/dev/null 2>&1; then
      echo "Removing existing image: $IMAGE_REF"
      docker rmi -f "$IMAGE_REF"
      docker image prune -f || true
    fi
  fi

  echo "Starting timed docker pull..."
} | tee "$LOG_FILE"

examples/verification/measure_time_setup.sh docker "$SETUP_CMD" 2>&1 | tee -a "$LOG_FILE"

echo "Completed Docker run for ${TOOL}." | tee -a "$LOG_FILE"