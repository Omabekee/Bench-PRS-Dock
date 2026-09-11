#!/usr/bin/env python3
"""Build the tidy benchmark CSVs from the verified docker-vs-native results.
Writes benchmark_runs / benchmark_summary / consistency into ../results/.
"""
import csv, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "local", "results")
os.makedirs(OUT, exist_ok=True)

# tool: (native n1/n2/n3, docker n1/n2/n3) wall-seconds
SETUP = {
 "PRSice":   ([527.34,524.66,435.81],[21.52,30.31,18.07]),
 "PRS-CSx":  ([125.66,109.62,153.95],[43.63,51.66,141.54]),
 "SDPRX":    ([146.79,158.70,145.84],[45.53,13.71,13.03]),
 "TL-PRS":   ([640.14,719.91,664.92],[155.42,134.20,142.30]),
 "XPASS":    ([754.87,626.67,780.01],[179.28,173.18,183.77]),
 "BridgePRS":([574.0,335.58,578.02],[196.15,184.37,137.45]),
 "JointPRS": ([547.10,893.70,867.80],[63.59,50.57,59.72]),
 "CT-SLEB":  ([452.77,486.75,568.98],[68.31,76.04,86.40]),
 "XP-BLUP":  ([64.17,57.36,57.65],[30.75,16.18,25.36]),
}
# tool: (native exec, docker exec, native_ram, docker_ram, scope)
EXEC = {
 "PRSice":   ([9.42,7.97,7.27],[15.92,13.98,13.26],191,186,"genomewide"),
 "TL-PRS":   ([554.80,689.81,574.71],[579.85,381.58,327.26],1001,988,"genomewide"),
 "XPASS":    ([218.90,193.05,268.09],[163.88,147.09,126.43],9855,9734,"genomewide"),
 "XPASS+":   ([148.02,187.74,204.96],[154.37,137.67,144.64],9727,8659,"genomewide"),
 "BridgePRS":([4332.24,4254.83,4191.20],[5507.44,5471.77,3534.28],3323,3311,"genomewide"),
 "CT-SLEB":  ([2445.33,3229.33,3547.13],[2902.45,2953.26,4042.99],3117,3157,"genomewide"),
 # MCMC tools
 "PRS-CSx":  ([6963.12,4838.19,6489.31],[4491.80,4711.63,5587.02],736,737,"genomewide"),
 "JointPRS": ([4704.05,5490.43,4681.11],[5638.21,5840.57,4805.57],735,734,"genomewide"),
 "SDPRX":    ([4693.73,4032.74,4110.64],[4407.04,4320.96,4397.37],1537,1534,"genomewide"),
 "XP-BLUP":  ([210.45,210.83,206.25],[219.65,204.59,206.69],2666,2665,"genomewide"),
}

# Consistency is assessed on the PER-INDIVIDUAL score for every tool, so the tools are
# directly comparable. PRS-CSx, SDPRX and JointPRS emit per-SNP posterior effects only,
# so their scores were produced by plink --score from those weights.
# tool: (verdict, pearson_r, spearman_rho, top10pct_overlap, type)
CONSIST = {
 "PRSice":   ("IDENTICAL", 1.0,      1.0,      1.0,    "deterministic"),
 "PRS-CSx":  ("IDENTICAL", 1.0,      1.0,      1.0,    "seeded MCMC"),
 "SDPRX":    ("DIFFER",    0.913186, 0.904090, 0.7197, "unseeded MCMC"),
 "TL-PRS":   ("IDENTICAL", 1.0,      1.0,      1.0,    "deterministic"),
 "XPASS":    ("IDENTICAL", 1.0,      1.0,      1.0,    "deterministic"),
 "XPASS+":   ("IDENTICAL", 1.0,      1.0,      1.0,    "deterministic"),
 "BridgePRS":("DIFFER",    1.0,      1.0,      1.0,    "stochastic (agrees to ~7 decimals)"),
 "JointPRS": ("IDENTICAL", 1.0,      1.0,      1.0,    "seeded MCMC"),
 "CT-SLEB":  ("IDENTICAL", 1.0,      1.0,      1.0,    "seeded ensemble"),
 "XP-BLUP":  ("IDENTICAL", 1.0,      1.0,      1.0,    "deterministic (GCTA+plink, 1-thread)"),
}
ORDER = ["PRSice","PRS-CSx","SDPRX","TL-PRS","XPASS","XPASS+","BridgePRS","JointPRS","CT-SLEB","XP-BLUP"]

def mean(x): return sum(x)/len(x)

# 1) tidy long: one row per tool/phase/scope/mode/rep
rows=[]
for t in ORDER:
    if t in SETUP:
        nat,doc=SETUP[t]
        for i,(n,d) in enumerate(zip(nat,doc),1):
            rows.append([t,"setup","-","native",i,n,""])
            rows.append([t,"setup","-","docker",i,d,""])
    if t in EXEC:
        nat,doc,nr,dr,sc=EXEC[t]
        for i,(n,d) in enumerate(zip(nat,doc),1):
            rows.append([t,"exec",sc,"native",i,n,nr])
            rows.append([t,"exec",sc,"docker",i,d,dr])
with open(os.path.join(OUT,"benchmark_runs.csv"),"w",newline="") as f:
    w=csv.writer(f); w.writerow(["tool","phase","scope","mode","rep","wall_s","peak_rss_mib"]); w.writerows(rows)

# 2) summary: mean per tool/phase/mode + consistency
srows=[]
for t in ORDER:
    if t in SETUP:
        nat,doc=SETUP[t]; srows.append([t,"setup","-","native",round(mean(nat),2),min(nat),max(nat),""])
        srows.append([t,"setup","-","docker",round(mean(doc),2),min(doc),max(doc),""])
    if t in EXEC:
        nat,doc,nr,dr,sc=EXEC[t]
        srows.append([t,"exec",sc,"native",round(mean(nat),2),min(nat),max(nat),nr])
        srows.append([t,"exec",sc,"docker",round(mean(doc),2),min(doc),max(doc),dr])
with open(os.path.join(OUT,"benchmark_summary.csv"),"w",newline="") as f:
    w=csv.writer(f); w.writerow(["tool","phase","scope","mode","mean_s","min_s","max_s","peak_rss_mib"]); w.writerows(srows)

with open(os.path.join(OUT,"consistency.csv"),"w",newline="") as f:
    w=csv.writer(f); w.writerow(["tool","verdict","pearson_r","spearman_rho","top10pct_overlap","type"])
    for t in ORDER:
        v,r,rho,top,ty=CONSIST[t]; w.writerow([t,v,r,rho,top,ty])

print("wrote benchmark_runs.csv, benchmark_summary.csv, consistency.csv to", OUT)
print(f"long rows: {len(rows)} | tools: {len(ORDER)}")
