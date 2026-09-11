#!/usr/bin/env bash
# Runs ON THE BOX. Polls until transferred inputs match the laptop manifests,
# then launches the benchmark driver. Survives the laptop sleeping or going offline.
B=$HOME/obj1_hpc
V=$B/logs/verify.log
M=$B/manifests
DEADLINE=$(( $(date +%s) + 8*3600 ))

ITEMS="prsice:inputs/preprocessed_prsice_output
prscsx:inputs/preprocessed_prscsx_output
sdprx:inputs/preprocessed_sdprx_output
tlprs:inputs/preprocessed_tlprs_output
xpassgw:inputs/preprocessed_xpass_genomewide
pheno:inputs/preprocessed_pheno
refstlprs:refs/tlprs
refsxpass:refs/xpass
jpsumstats:inputs/jointprs/sumstats
ctsleb:inputs/preprocessed_ctsleb_output
eurldref:ldref/EUR_ldref
afrldref:ldref/AFR_ldref
bridgeprs:inputs/preprocessed_bridgeprs_output
split:split/AFR/genotype"

check () {  # check <name> <relpath> -> 0 ok
  local n="$1" p="$2"
  [ -f "$M/$n.txt" ] || return 1
  if [ "$n" = "split" ]; then
    ( cd "$B/$p" 2>/dev/null && ls AFR_seed44_valid.* AFR_seed44_test.* 2>/dev/null | grep -v Zone | sort | while read f; do sha256sum "$f"; done ) > /tmp/box_$n.txt 2>/dev/null
  else
    ( cd "$B/$p" 2>/dev/null && find . -type f ! -name '*Zone.Identifier' | sort | while read f; do sha256sum "$f"; done ) > /tmp/box_$n.txt 2>/dev/null
  fi
  diff -q <(sort "$M/$n.txt") <(sort /tmp/box_$n.txt) > /dev/null 2>&1
}

echo "=== box verifier started $(date -Is) ===" >> $V
while true; do
  FAILED=""; PENDING=0
  for it in $ITEMS; do
    n="${it%%:*}"; p="${it##*:}"
    if [ ! -f "$M/$n.txt" ]; then PENDING=1; continue; fi
    check "$n" "$p" || FAILED="$FAILED $n"
  done
  NOW=$(date +%s)
  if [ -z "$FAILED" ] && [ "$PENDING" = "0" ]; then
    echo "[$(date +%H:%M:%S)] ALL INPUTS VERIFIED IDENTICAL" >> $V; break
  fi
  if [ "$NOW" -ge "$DEADLINE" ]; then
    echo "[$(date +%H:%M:%S)] DEADLINE reached. unverified:$FAILED pending=$PENDING" >> $V; break
  fi
  echo "[$(date +%H:%M:%S)] waiting; unverified:${FAILED:- none} pending=$PENDING" >> $V
  sleep 300
done

# any input that did not verify disables the tools that depend on it
skip () { touch $B/logs/SKIP_$1; echo "[$(date +%H:%M:%S)] SKIP $1 (inputs unverified)" >> $V; }
for f in $FAILED; do
  case $f in
    prsice)     skip prsice ;;
    prscsx)     skip prscsx_gw; skip jointprs_gw ;;
    sdprx)      skip sdprx_gw ;;
    tlprs)      skip tlprs; skip xpblup ;;
    refstlprs)  skip tlprs ;;
    xpassgw|refsxpass) skip xpass; skip "xpass+" ;;
    jpsumstats) skip jointprs_gw ;;
    ctsleb|eurldref|afrldref) skip ctsleb ;;
    split)      skip ctsleb; skip xpblup ;;
    pheno)      skip xpblup ;;
    bridgeprs)  skip bridgeprs ;;
  esac
done

echo "[$(date +%H:%M:%S)] submitting slurm chain" >> $V
bash $B/harness/submit_chain.sh >> $V 2>&1
echo "[$(date +%H:%M:%S)] chain submitted; slurm now owns the run" >> $V
