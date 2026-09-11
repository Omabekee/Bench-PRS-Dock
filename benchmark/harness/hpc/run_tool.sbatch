#!/usr/bin/env bash
#SBATCH --partition=workshop
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --output=$HOME/obj1_hpc/logs/slurm_%x_%j.out
#SBATCH --error=$HOME/obj1_hpc/logs/slurm_%x_%j.err
# One tool, n=3 replicates (cold pull -> sandbox -> exec per replicate).
# Runs INSIDE the allocation, so pull and sandbox extraction are covered by --mem too.
set -u
TOOL="$1"
B=$HOME/obj1_hpc
LOG=$B/logs/drive.log

if [ -f "$B/logs/SKIP_$TOOL" ]; then
  echo "[$(date +%H:%M:%S)] SKIP $TOOL (inputs unverified)" >> $LOG; exit 0
fi

echo "[$(date +%H:%M:%S)] ==== $TOOL (job $SLURM_JOB_ID) ====" >> $LOG
for rep in 1 2 3; do
  AVAIL=$(quota -s 2>/dev/null | awk 'NR==3{gsub(/[MG]/,"",$2); print 92160-$2}')
  if [ -n "${AVAIL:-}" ] && [ "$AVAIL" -lt 10240 ] 2>/dev/null; then
    echo "[$(date +%H:%M:%S)] ABORT $TOOL: quota headroom ${AVAIL}M < 10G" >> $LOG; exit 1
  fi
  echo "[$(date +%H:%M:%S)] $TOOL rep$rep start" >> $LOG
  OUT=$(python3 $B/harness/run_hpc.py "$TOOL" "$rep" 2>>$LOG)
  echo "[$(date +%H:%M:%S)] $TOOL rep$rep -> $OUT" >> $LOG
  if [ "$rep" = "1" ] && ! echo "$OUT" | grep -q '"exit": 0'; then
    echo "[$(date +%H:%M:%S)] $TOOL rep1 FAILED, skipping reps 2-3" >> $LOG; break
  fi
done
echo "[$(date +%H:%M:%S)] ==== $TOOL done ====" >> $LOG
