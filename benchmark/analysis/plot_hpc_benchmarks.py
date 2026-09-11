#!/usr/bin/env python3
"""
Objective 1: laptop versus HPC comparison plots.
Style follows plot_obj1_benchmarks.py so the figures sit alongside the existing set.

The three bars are ENVIRONMENTS, not container runtimes. Native and Docker both ran on
the laptop (Intel i7-7600U, 4 cores, contended desktop), so that pair isolates the cost
of containerising. Apptainer ran on the HPC (Intel Xeon Gold 6248, reserved Slurm
allocation), so its bar also carries the change of machine. Legend labels say which.

Setup is plotted on its own because apptainer pull and docker pull ran on different
networks, which makes a side by side setup comparison meaningless.
"""
import csv, os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "..", "hpc", "results", "benchmark_runs.csv")
OUT_DIR = os.path.join(HERE, "..", "hpc", "figures")
os.makedirs(OUT_DIR, exist_ok=True)

# Laptop genome-wide n=3, copied from plot_obj1_benchmarks.py so both figure sets agree.
LAPTOP_EXEC = {
    "PRSice":   ([9.42, 7.97, 7.27],             [15.92, 13.98, 13.26]),
    "PRS-CSx":  ([6963.12, 4838.19, 6489.31],    [4491.80, 4711.63, 5587.02]),
    "SDPRX":    ([4693.73, 4032.74, 4110.64],    [4407.04, 4320.96, 4397.37]),
    "TL-PRS":   ([554.80, 689.81, 574.71],       [579.85, 381.58, 327.26]),
    "XPASS":    ([218.90, 193.05, 268.09],       [163.88, 147.09, 126.43]),
    "XPASS+":   ([148.02, 187.74, 204.96],       [154.37, 137.67, 144.64]),
    "BridgePRS":([4332.24, 4254.83, 4191.20],    [5507.44, 5471.77, 3534.28]),
    "JointPRS": ([4704.05, 5490.43, 4681.11],    [5638.21, 5840.57, 4805.57]),
    "CT-SLEB":  ([2445.33, 3229.33, 3547.13],    [2902.45, 2953.26, 4042.99]),
    "XP-BLUP":  ([210.45, 210.83, 206.25],       [219.65, 204.59, 206.69]),
}
# Laptop setup n=3 (native install, docker cold pull), same source file.
LAPTOP_SETUP = {
    "PRSice":   ([527.34, 524.66, 435.81],  [21.52, 30.31, 18.07]),
    "PRS-CSx":  ([125.66, 109.62, 153.95],  [43.63, 51.66, 141.54]),
    "SDPRX":    ([146.79, 158.70, 145.84],  [45.53, 13.71, 13.03]),
    "TL-PRS":   ([640.14, 719.91, 664.92],  [155.42, 134.20, 142.30]),
    "XPASS":    ([754.87, 626.67, 780.01],  [179.28, 173.18, 183.77]),
    "XPASS+":   ([754.87, 626.67, 780.01],  [179.28, 173.18, 183.77]),
    "BridgePRS":([574.00, 335.58, 578.02],  [196.15, 184.37, 137.45]),
    "JointPRS": ([547.10, 893.70, 867.80],  [63.59, 50.57, 59.72]),
    "CT-SLEB":  ([452.77, 486.75, 568.98],  [68.31, 76.04, 86.40]),
    "XP-BLUP":  ([64.17, 57.36, 57.65],     [30.75, 16.18, 25.36]),
}
TOOLS = list(LAPTOP_EXEC.keys())

C_MANUAL    = "#E9C46A"   # warm gold
C_DOCKER    = "#457B9D"   # steel blue
C_APPTAINER = "#2A9D8F"   # teal

def load_apptainer():
    exec_, setup = {t: [] for t in TOOLS}, {t: [] for t in TOOLS}
    for r in csv.DictReader(open(RESULTS)):
        if r["tool"] not in exec_: continue
        (exec_ if r["phase"] == "exec" else setup)[r["tool"]].append(float(r["wall_s"]))
    return exec_, setup

def style_ax(ax, ylabel, xlabel="PRS Tool"):
    ax.set_ylabel(ylabel, fontsize=15, fontweight="bold")
    ax.set_xlabel(xlabel, fontsize=15, fontweight="bold")
    ax.tick_params(axis="both", labelsize=13)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.yaxis.grid(True, alpha=0.3, linestyle="--")
    ax.set_axisbelow(True)

def save(fig, name):
    p = os.path.join(OUT_DIR, name)
    fig.savefig(p, dpi=600, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print("  Saved:", os.path.normpath(p))

def mean_sd(vals):
    return np.array([np.mean(vals[t]) for t in TOOLS]), \
           np.array([np.std(vals[t], ddof=1) for t in TOOLS])

def plot_three(app_exec, filename, logy=False, laptop=None, ylab="Execution time"):
    laptop = laptop or LAPTOP_EXEC
    m_mean, m_sd = mean_sd({t: laptop[t][0] for t in TOOLS})
    d_mean, d_sd = mean_sd({t: laptop[t][1] for t in TOOLS})
    a_mean, a_sd = mean_sd(app_exec)
    x, w = np.arange(len(TOOLS)), 0.27
    fig, ax = plt.subplots(figsize=(13, 6))
    for off, mean, sd, col, lab in (
        (-w, m_mean, m_sd, C_MANUAL,    "Native"),
        (0,  d_mean, d_sd, C_DOCKER,    "Docker"),
        (w,  a_mean, a_sd, C_APPTAINER, "Apptainer")):
        ax.bar(x + off, mean, w, yerr=sd, color=col, edgecolor="black", linewidth=0.7,
               capsize=4, error_kw={"linewidth": 1.2}, label=lab, alpha=0.90)
    if logy:
        ax.set_yscale("log"); ax.set_ylim(bottom=1)
    ax.set_xticks(x)
    ax.set_xticklabels(TOOLS, fontsize=12, fontweight="bold", rotation=30, ha="right")
    style_ax(ax, f"{ylab} (seconds, log scale)" if logy else f"{ylab} (seconds)")
    # Legend sits above the axes so it cannot cover a tall bar (it overlapped CT-SLEB
    # on the log scale when placed inside).
    ax.legend(fontsize=12, frameon=True, edgecolor="gray", ncol=3,
              loc="lower center", bbox_to_anchor=(0.5, 1.01))
    fig.tight_layout(); save(fig, filename)

def plot_variability(app_exec, filename):
    """Run to run spread, as coefficient of variation. Lower is more reproducible."""
    def cv(vals): 
        return np.array([100 * np.std(vals[t], ddof=1) / np.mean(vals[t]) for t in TOOLS])
    m = cv({t: LAPTOP_EXEC[t][0] for t in TOOLS})
    d = cv({t: LAPTOP_EXEC[t][1] for t in TOOLS})
    a = cv(app_exec)
    x, w = np.arange(len(TOOLS)), 0.27
    fig, ax = plt.subplots(figsize=(13, 6))
    for off, v, col, lab in ((-w, m, C_MANUAL, "Native"),
                             (0,  d, C_DOCKER, "Docker"),
                             (w,  a, C_APPTAINER, "Apptainer")):
        ax.bar(x + off, v, w, color=col, edgecolor="black", linewidth=0.7, label=lab, alpha=0.90)
    ax.set_xticks(x)
    ax.set_xticklabels(TOOLS, fontsize=12, fontweight="bold", rotation=30, ha="right")
    style_ax(ax, "Run to run variation (CV, %)")
    ax.legend(fontsize=12, frameon=True, edgecolor="gray", ncol=3,
              loc="lower center", bbox_to_anchor=(0.5, 1.01))
    fig.tight_layout(); save(fig, filename)

def plot_setup(app_setup, filename):
    mean, sd = mean_sd(app_setup)
    x = np.arange(len(TOOLS))
    fig, ax = plt.subplots(figsize=(12, 5.5))
    ax.bar(x, mean, 0.6, yerr=sd, color=C_APPTAINER, edgecolor="black", linewidth=0.7,
           capsize=4, error_kw={"linewidth": 1.2}, alpha=0.90)
    ax.set_xticks(x)
    ax.set_xticklabels(TOOLS, fontsize=12, fontweight="bold", rotation=30, ha="right")
    style_ax(ax, "Image pull time on the HPC (seconds)")
    fig.tight_layout(); save(fig, filename)

if __name__ == "__main__":
    ae, asu = load_apptainer()
    print("Figures:")
    plot_three(ae, "fig_exec_three_environments.png")
    plot_three(ae, "fig_exec_three_environments_log.png", logy=True)
    plot_variability(ae, "fig_exec_variability.png")
    plot_setup(asu, "fig_setup_apptainer_hpc.png")
    # Setup across all three environments. The laptop native bar is a real install from
    # source; both container bars are cold image pulls, and the two pulls ran on
    # different networks, so read the container bars with that in mind.
    app_setup_pairs = {t: (LAPTOP_SETUP[t][0], LAPTOP_SETUP[t][1]) for t in TOOLS}
    plot_three(asu, "fig_setup_three_environments.png",
               laptop=app_setup_pairs, ylab="Setup time")
    plot_three(asu, "fig_setup_three_environments_log.png", logy=True,
               laptop=app_setup_pairs, ylab="Setup time")
