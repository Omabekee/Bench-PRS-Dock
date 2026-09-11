#!/usr/bin/env python3
"""
Benchmarking plots (setup + execution, native vs docker) for all 10 tools.
Data are the genome-wide mean +/- SD (n=3) from the benchmark results.
Figures are written to ../figures/.
"""
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SCRIPT_DIR, "..", "local", "figures")
os.makedirs(OUT_DIR, exist_ok=True)

# ══════════════════════════════════════════════════════════════
# DATA - raw n=3 (native, docker). Genome-wide scope for every tool.
# XPASS+ shares the XPASS conda env -> identical setup values.
# ══════════════════════════════════════════════════════════════
SETUP_RAW = {
    "PRSice":   ([527.34, 524.66, 435.81],     [21.52, 30.31, 18.07]), 
    "PRS-CSx":  ([125.66, 109.62, 153.95],    [43.63, 51.66, 141.54]),
    "SDPRX":    ([146.79, 158.70, 145.84],     [45.53, 13.71, 13.03]),
    "TL-PRS":   ([640.14, 719.91, 664.92],     [155.42, 134.20, 142.30]),
    "XPASS":    ([754.87, 626.67, 780.01],     [179.28, 173.18, 183.77]),
    "XPASS+":   ([754.87, 626.67, 780.01],     [179.28, 173.18, 183.77]),  # shares XPASS env
    "BridgePRS":([574.0, 335.58, 578.02],      [196.15, 184.37, 137.45]),
    "JointPRS": ([547.10, 893.70, 867.80],     [63.59, 50.57, 59.72]),
    "CT-SLEB":  ([452.77, 486.75, 568.98],     [68.31, 76.04, 86.40]),
    "XP-BLUP":  ([64.17, 57.36, 57.65],        [30.75, 16.18, 25.36]),
}
RUNTIME_RAW = {
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
TOOLS = list(SETUP_RAW.keys())

def _stats(raw):
    return {
        "manual_mean": np.array([np.mean(raw[t][0]) for t in TOOLS]),
        "manual_sd":   np.array([np.std(raw[t][0], ddof=1) for t in TOOLS]),
        "docker_mean": np.array([np.mean(raw[t][1]) for t in TOOLS]),
        "docker_sd":   np.array([np.std(raw[t][1], ddof=1) for t in TOOLS]),
    }
SETUP = _stats(SETUP_RAW)
RUNTIME = _stats(RUNTIME_RAW)

# Colors
C_MANUAL = "#E9C46A"   # warm gold
C_DOCKER = "#457B9D"   # steel blue

# Tool-specific colors for the ratio plots
RATIO_COLORS = ["#264653", "#2A9D8F", "#E9C46A", "#F4A261", "#E76F51",
                "#8AB17D", "#0A9396", "#EE9B00", "#CA6702", "#9B2226"]


# ══════════════════════════════════════════════════════════════
# STYLE HELPERS
# ══════════════════════════════════════════════════════════════
def style_ax(ax, ylabel, xlabel="PRS Tool"):
    ax.set_ylabel(ylabel, fontsize=15, fontweight="bold")
    ax.set_xlabel(xlabel, fontsize=15, fontweight="bold")
    ax.tick_params(axis="both", labelsize=13)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.yaxis.grid(True, alpha=0.3, linestyle="--")
    ax.set_axisbelow(True)


def save(fig, name):
    path = os.path.join(OUT_DIR, name)
    fig.savefig(path, dpi=600, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"  Saved: {path}")


# ══════════════════════════════════════════════════════════════
# PLOT 1 & 2:  Grouped bar charts (Native vs Docker)
# ══════════════════════════════════════════════════════════════
def plot_grouped_bars(data, title_phase, filename, logy=False):
    x = np.arange(len(TOOLS))
    w = 0.35

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.bar(x - w/2, data["manual_mean"], w, yerr=data["manual_sd"],
           color=C_MANUAL, edgecolor="black", linewidth=0.7,
           capsize=4, error_kw={"linewidth": 1.2}, label="Native", alpha=0.90)
    ax.bar(x + w/2, data["docker_mean"], w, yerr=data["docker_sd"],
           color=C_DOCKER, edgecolor="black", linewidth=0.7,
           capsize=4, error_kw={"linewidth": 1.2}, label="Docker", alpha=0.90)

    if logy:                            # exec spans ~8s-6100s; log keeps fast tools visible
        ax.set_yscale("log")
        ax.set_ylim(bottom=1)
    ax.set_xticks(x)
    ax.set_xticklabels(TOOLS, fontsize=12, fontweight="bold", rotation=30, ha="right")
    style_ax(ax, ylabel="Time (seconds, log scale)" if logy else "Time (seconds)")
    ax.legend(fontsize=13, frameon=True, edgecolor="gray", loc="upper right")

    fig.tight_layout()
    save(fig, filename)


# ══════════════════════════════════════════════════════════════
# PLOT 3 & 4:  Efficiency ratio bars
# ══════════════════════════════════════════════════════════════
def plot_ratio(data, title_phase, filename, ylabel, yticks=None, ymax=None):
    ratios = data["manual_mean"] / data["docker_mean"]

    fig, ax = plt.subplots(figsize=(11, 5.5))
    bars = ax.bar(TOOLS, ratios, width=0.55, color=RATIO_COLORS,
                  edgecolor="black", linewidth=0.7, alpha=0.90)

    ax.axhline(y=1.0, color="#d62728", linestyle="--", linewidth=1.5, zorder=0)

    top = ymax if ymax else max(ratios) * 1.25
    for bar, r in zip(bars, ratios):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + top*0.02,
                f"{r:.1f}×", ha="center", va="bottom", fontsize=12,
                fontweight="bold", color="#333333")

    ax.set_ylim(0, top)
    if yticks:
        ax.set_yticks(yticks)
    ax.set_xticks(range(len(TOOLS)))
    ax.set_xticklabels(TOOLS, fontsize=12, fontweight="bold", rotation=30, ha="right")
    style_ax(ax, ylabel=ylabel)

    fig.tight_layout()
    save(fig, filename)


# ══════════════════════════════════════════════════════════════
# GENERATE ALL
# ══════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("Generating Objective 1 benchmark plots (10 tools, genome-wide)...")

    # linear (primary) + log (evidence) versions of both comparison figures
    plot_grouped_bars(SETUP, "Setup Phase", "fig_setup_time_comparison.png")
    plot_grouped_bars(SETUP, "Setup Phase", "fig_setup_time_comparison_log.png", logy=True)
    plot_grouped_bars(RUNTIME, "Execution Phase", "fig_runtime_comparison.png")
    plot_grouped_bars(RUNTIME, "Execution Phase", "fig_runtime_comparison_log.png", logy=True)
    plot_ratio(SETUP, "Setup Phase", "fig_setup_efficiency_ratio.png",
               "Setup Ratio (>1 = Docker faster)")
    plot_ratio(RUNTIME, "Execution Phase", "fig_runtime_efficiency_ratio.png",
               "Runtime Ratio (>1 = Docker faster)")
    plot_ratio(RUNTIME, "Execution Phase", "fig_runtime_efficiency_ratio_scale246.png",
               "Runtime Ratio (>1 = Docker faster)", yticks=[2, 4, 6], ymax=6.5)

    print("Done! All plots in:", OUT_DIR)
