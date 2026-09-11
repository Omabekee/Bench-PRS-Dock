#!/usr/bin/env bash
# Submit all 10 tools as a serial sbatch dependency chain.
# Serial by design: concurrent tools would contaminate wall-time.
B=$HOME/obj1_hpc
LOG=$B/logs/drive.log
declare -A TIME=( [prsice]=01:00:00 [xpass]=02:00:00 [xpass+]=02:00:00 [xpblup]=02:00:00
                  [tlprs]=03:00:00 [ctsleb]=08:00:00 [sdprx_gw]=10:00:00 [bridgeprs]=12:00:00
                  [prscsx_gw]=12:00:00 [jointprs_gw]=14:00:00 )
TOOLS="prsice xpass xpass+ xpblup tlprs ctsleb sdprx_gw bridgeprs prscsx_gw jointprs_gw"

PREV=""
echo "=== submitting chain $(date -Is) ===" >> $LOG
for t in $TOOLS; do
  DEP=""; [ -n "$PREV" ] && DEP="--dependency=afterany:$PREV"
  JID=$(sbatch --parsable --job-name="obj1_$t" --time="${TIME[$t]}" $DEP \
        $B/harness/run_tool.sbatch "$t")
  echo "[$(date +%H:%M:%S)] submitted $t as job $JID ${DEP:+(after $PREV)}" >> $LOG
  PREV=$JID
done
echo "=== chain submitted, last job $PREV ===" >> $LOG
squeue -u $USER -o "%.8i %.14j %.10T %.12l %.20E" >> $LOG
