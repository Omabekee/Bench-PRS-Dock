#!/usr/bin/env bash
# =============================================================
# Script: capture_system_info.sh
# Purpose: Record system and environment context for reproducibility
# Usage: bash examples/verification/capture_system_info.sh
# =============================================================

OUTPUT_FILE="examples/verification/system_info_night.txt"
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")

mkdir -p "$OUTPUT_DIR"

if [ -f "$OUTPUT_FILE" ]; then
  echo "System info file already exists at $OUTPUT_FILE"
  echo "   Delete it manually if you want to refresh the info."
  exit 0
fi

echo "📋 Recording system information..."

{
  echo "===== SYSTEM INFO ====="
  echo "Date: $(date)"
  echo "OS: $(uname -a)"
  echo "CPU Info: $(lscpu | grep 'Model name')"
  echo "Cores: $(nproc)"
  echo "RAM: $(free -h | awk '/Mem:/ {print $2}')"

  echo "Disk Type:"
  lsblk -o NAME,ROTA | grep -v 'ROTA' | while read -r name rota; do
    if [ "$rota" = "0" ]; then
      echo "  $name (SSD)"
    elif [ "$rota" = "1" ]; then
      echo "  $name (HDD)"
    fi
  done

  echo "Conda Version: $(conda --version 2>/dev/null)"
  echo "Docker Version: $(docker --version 2>/dev/null)"
  echo "Python Version: $(python --version 2>/dev/null)"
  echo "Network Speed Test (approx):"
  ping -c 3 google.com | grep 'avg' || echo "Ping test failed"
} > "$OUTPUT_FILE"

echo "System information saved to $OUTPUT_FILE"